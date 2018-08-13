import argparse
import io
import logging
import os
import sys
import time

import mutagen
from mutagen.mp4 import MP4

try:
    from StringIO import StringIO
except ImportError:
    from io import StringIO

valid_output_extensions = ("mp4", "m4v")
list_separator = ","
collections_separator = "/"


class HomeVideoFile:
    def __init__(self, title, description, comment, people, camera_operator, collections, clip_number, clip_total, chapter_number, chapter_total, date, title_sort, language='en', logger=None, original=None):

        if logger:
            self.log = logger
        else:
            self.log = logging.getLogger(__name__)

        self.camera_operator = list_separator.join(camera_operator)
        self.chapter_number = chapter_number
        self.chapter_total = chapter_total
        self.clip_number = clip_number
        self.clip_total = clip_total
        self.collections = collections
        print(self.collections)
        self.comment = comment
        self.date = date
        self.description = description
        self.HD = None
        self.Original = original
        self.people = list_separator.join(people)
        self.title = title
        self.title_sort = title_sort
        self.writer = None
        self.xml = self.xmlTags().encode('ascii', errors='ignore')

    def writeTags(self, mp4Path):
        self.log.info("Tagging file: %s." % mp4Path)
        ext = os.path.splitext(mp4Path)[1][1:]
        if ext not in valid_output_extensions:
            self.log.error("File is not the correct format.")
            sys.exit()

        video = MP4(mp4Path)

        # XML - see xmlTags method
        video["----:com.apple.iTunes:iTunMOVI"] = self.xml
        video["desc"] = self.description  # Clip title as short description
        video["ldes"] = self.description  # Clip title as short description
        # Chapter number/total as disk
        video["disk"] = [(self.chapter_number, self.chapter_total)]
        video["sonm"] = self.title_sort  # Episode number iTunes
        video["trkn"] = [(self.clip_number, self.clip_total)
                         ]  # Clip number/total as track
        video["\xa9ART"] = self.people  # People as artists (delimated by ",")
        # Collections as album name (delimated by "/")
        video["\xa9alb"] = self.collections
        # "Disc [Disc Name], Chapter [Chapter], Clip [Clip]" as comment
        video["\xa9cmt"] = self.comment
        video["\xa9day"] = self.date  # Clip date
        video["\xa9nam"] = self.title  # Clip title
        video["stik"] = [0]  # Home video iTunes category

        MP4(mp4Path).delete(mp4Path)
        for i in range(3):
            try:
                self.log.info("Trying to write tags.")
                video.save()
                self.log.info("Tags written successfully.")
                break
            except IOError as e:
                self.log.exception(
                    "There was a problem writing the tags. Retrying.")
                time.sleep(5)

    def setHD(self, width, height):
        if width >= 1900 or height >= 1060:
            self.HD = [2]
        elif width >= 1260 or height >= 700:
            self.HD = [1]
        else:
            self.HD = [0]

    def shortDescription(self, length=255, splitter='.', suffix='.'):
        if self.description is None:
            self.description = ''
        if len(self.description) <= length:
            return self.description
        else:
            return ' '.join(self.description[:length + 1].split('.')[0:-1]) + suffix

    def xmlTags(self):
        # constants
        header = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict>\n"
        castheader = "<key>cast</key><array>\n"
        writerheader = "<key>screenwriters</key><array>\n"
        directorheader = "<key>directors</key><array>\n"
        subfooter = "</array>\n"
        footer = "</dict></plist>\n"

        output = StringIO()
        output.write(header)

        # Write actors
        output.write(castheader)
        for name in self.people.split(list_separator):
            if name is not None:
                output.write(
                    "<dict><key>name</key><string>%s</string></dict>\n" % name)
        output.write(subfooter)

        # Write screenwriterr
        if self.writer is not None:
            output.write(writerheader)
            for name in self.writer.split(list_separator):
                if name != "":
                    output.write(
                        "<dict><key>name</key><string>%s</string></dict>\n" % name)
            output.write(subfooter)

        # Write directors
        if self.camera_operator is not None:
            output.write(directorheader)
            for name in self.camera_operator.split(list_separator):
                if name != "":
                    output.write(
                        "<dict><key>name</key><string>%s</string></dict>\n" % name)
            output.write(subfooter)

        # Close XML
        output.write(footer)
        return output.getvalue()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--File", help="File to be edited")
    parser.add_argument("--Title", help="MP4 Title tag")
    parser.add_argument("--Description", help="MP4 description tag")
    parser.add_argument("--Comment", help="MP4 comment tag")
    parser.add_argument("--People", nargs='+', help="MP4 People tag")
    parser.add_argument("--CameraOperators", nargs='+',
                        help="MP4 Camera operators tag")
    parser.add_argument("--Collections", nargs='+', help="MP4 Collections tag")
    parser.add_argument("--ClipNumber", type=int, help="MP4 Clip number tag")
    parser.add_argument("--ClipTotal", type=int, help="MP4 Clip total tag")
    parser.add_argument("--ChapterNumber", type=int,
                        help="MP4 Chapter number tag")
    parser.add_argument("--ChapterTotal", type=int,
                        help="MP4 Chapter total tag")
    parser.add_argument("--Date", help="MP4 Date tag")
    parser.add_argument("--TitleSort", help="MP4 Sort title tag")

    args = parser.parse_args()

    Arg_File = str(args.File).replace("\\", "/")
    Arg_Title = args.Title
    Arg_Description = args.Description
    Arg_Comment = args.Comment
    Arg_People = args.People
    Arg_CameraOperators = args.CameraOperators
    Arg_Collections = collections_separator.join(args.Collections)
    Arg_ClipNumber = int(args.ClipNumber)
    Arg_ClipTotal = int(args.ClipTotal)
    Arg_ChapterNumber = int(args.ChapterNumber)
    Arg_ChapterTotal = int(args.ChapterTotal)
    Arg_Date = args.Date
    Arg_TitleSort = args.TitleSort

    HomeVideoFile_instance = HomeVideoFile(Arg_Title, Arg_Description, Arg_Comment, Arg_People, Arg_CameraOperators,
                                           Arg_Collections, Arg_ClipNumber, Arg_ClipTotal, Arg_ChapterNumber, Arg_ChapterTotal, Arg_Date, Arg_TitleSort)
    if os.path.splitext(Arg_File)[1][1:] in valid_output_extensions:
        HomeVideoFile_instance.writeTags(Arg_File)
    else:
        print("Wrong file type")


if __name__ == '__main__':
    main()
