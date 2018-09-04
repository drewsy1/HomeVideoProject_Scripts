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
albums_separator = "/"


class HomeVideoFile:
    def __init__(self, title, description, comment, actors, director, album, track_number, track_total, disc_number, disc_total, date, title_sort, language='en', logger=None, original=None):

        if logger:
            self.log = logger
        else:
            self.log = logging.getLogger(__name__)

        self.director = list_separator.join(director)
        self.disc_number = disc_number
        self.disc_total = disc_total
        self.track_number = track_number
        self.track_total = track_total
        self.album = album
        self.comment = comment
        self.date = date
        self.description = description
        self.HD = None
        self.Original = original
        self.actors = list_separator.join(actors)
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
        # Chapter number/total as disc
        video["disc"] = [(self.disc_number, self.disc_total)]
        video["sonm"] = self.title_sort  # Episode number iTunes
        video["trkn"] = [(self.track_number, self.track_total)
                         ]  # Clip number/total as track
        video["\xa9ART"] = self.actors  # People as artists (delimated by ",")
        # Album as album name (delimated by "/")
        video["\xa9alb"] = self.album
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
        for name in self.actors.split(list_separator):
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
        if self.director is not None:
            output.write(directorheader)
            for name in self.director.split(list_separator):
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
    parser.add_argument("--Actors", nargs='+', help="MP4 Actors tag")
    parser.add_argument("--Director", nargs='+',
                        help="MP4 director tag")
    parser.add_argument("--Album", nargs='+', help="MP4 Album tag")
    parser.add_argument("--TrackNumber", type=int, help="MP4 track number tag")
    parser.add_argument("--TrackTotal", type=int, help="MP4 track total tag")
    parser.add_argument("--DiscNumber", type=int,
                        help="MP4 disc number tag")
    parser.add_argument("--DiscTotal", type=int,
                        help="MP4 Chapter total tag")
    parser.add_argument("--Date", help="MP4 Date tag")
    parser.add_argument("--TitleSort", help="MP4 Sort title tag")

    args = parser.parse_args()

    Arg_File = str(args.File).replace("\\", "/")
    Arg_Title = args.Title
    Arg_Description = args.Description
    Arg_Comment = args.Comment
    Arg_Actors = args.Actors
    Arg_Director = args.Director
    Arg_Album = albums_separator.join(args.Album)
    Arg_TrackNumber = int(args.TrackNumber)
    Arg_TrackTotal = int(args.TrackTotal)
    Arg_DiscNumber = int(args.DiscNumber)
    Arg_DiscNumberTotal = int(args.DiscTotal)
    Arg_Date = args.Date
    Arg_TitleSort = args.TitleSort

    HomeVideoFile_instance = HomeVideoFile(Arg_Title, Arg_Description, Arg_Comment, Arg_Actors, Arg_Director,
                                           Arg_Album, Arg_TrackNumber, Arg_TrackTotal, Arg_DiscNumber, Arg_DiscNumberTotal, Arg_Date, Arg_TitleSort)
    if os.path.splitext(Arg_File)[1][1:] in valid_output_extensions:
        HomeVideoFile_instance.writeTags(Arg_File)
    else:
        print("Wrong file type")


if __name__ == '__main__':
    main()
