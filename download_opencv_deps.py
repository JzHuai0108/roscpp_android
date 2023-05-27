import hashlib
import os
import shutil
import sys
import urllib.request


def checkmd5sum(filename, original_md5_string):
    # file_name = 'filename.exe'
    # Correct original md5 goes here
    # original_md5 = '5d41402abc4b2a76b9719d911017c592'

    # Open,close, read file and calculate MD5 on its contents
    with open(file_name, 'rb') as file_to_check:
        # read contents of the file
        data = file_to_check.read()
        # pipe contents of the file through
        md5_returned = hashlib.md5(data).hexdigest()

    # Finally compare original MD5 with freshly calculated
    if md5_returned in original_md5_string:
        return true
    else:
        return false

def findUrls(cvdownloadlog):
    urls = []
    with open(cvdownloadlog, 'r') as f:
        lines = f.readlines()
        for line in lines:
            if "https:" in line:
                segments = line.split('"')
                for segment in segments:
                    if "https:" in segment:
                        url = segment
                        urls.append(url)

    uniqueurls = []
    for i, url in enumerate(urls):
        if i > 0:
            if url == urls[i-1]:
                continue
            else:
                uniqueurls.append(url)
        else:
            uniqueurls.append(url)

    print("Found {} unique urls".format(len(uniqueurls)))
    for i, url in enumerate(uniqueurls):
        print("{}: {}".format(i, url))
    return urls


def downloadUrl(url, outputdir):
    localpath = os.path.join(outputdir, os.path.basename(url))
    if os.path.isfile(localpath):
        print("{} already downloaded.".format(localpath))
        return
    print('Downloading {}'.format(url))
    urllib.request.urlretrieve(url, localpath)

def renameFiles(srcdir, destdir):
    # find basefolder/hash-filename names from destdir
    targetfiles = []
    for root, dirs, fns in os.walk(destdir):
        for f in fns:
            targetfiles.append(os.path.join(root, f))
    for fn in os.listdir(srcdir):
        if os.path.isfile(os.path.join(srcdir, fn)):
            basename = os.path.basename(fn)
            for targetfile in targetfiles:
                if basename in targetfile:
                    md5match = checkmd5sum(os.path.join(srcdir, fn), targetfile)
                    if not md5match:
                        print("MD5 mismatch for {} and {}".format(os.path.join(srcdir, fn), targetfile))
                    else:
                        print("Renaming {} to {}".format(os.path.join(srcdir, fn), targetfile))
                        shutil.copyfile(os.path.join(srcdir, fn), targetfile)
                    break


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: {} <catkin_ws>".format(sys.argv[0]))
        print('Ex: {} /docker/ros_android/output/catkin_ws'.format(sys.argv[0]))
        sys.exit(-1)
    catkin_ws = sys.argv[1]
    cvdownloadlog = os.path.join(catkin_ws, "build/opencv3/CMakeDownloadLog.txt")

    tmpoutputdir = "/tmp/opencv/"
    destdir = os.path.join(catkin_ws, "src/opencv3/.cache")
    print("Downloading opencv dependencies to {}".format(destdir))

    urls = findUrls(cvdownloadlog)
    for url in urls:
        downloadUrl(url, tmpoutputdir)
    renameFiles(tmpoutputdir, destdir)
