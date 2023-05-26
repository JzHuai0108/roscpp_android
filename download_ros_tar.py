import os
import urllib.request
import shutil
import sys
import tarfile


def loadRosPackageList(rosinstallfile):
    packages = []
    with open(rosinstallfile, 'r') as f:
        lines = f.readlines()
        newentry = False
        for line in lines:
            if line.startswith("- tar:"):
                if newentry:
                    packages.append([localname, uri])
                    newentry = False
            if line.startswith("    local-name:"):
                localname = line.split(':')[1].strip()
                newentry = True
            if line.startswith("    uri:"):
                uri = line.strip('    uri:').strip()
                assert uri.endswith(".tar.gz"), "uri must end with .tar.gz, uri:{}".format(uri)
                newentry = True
        if newentry:
            packages.append([localname, uri])
        print("Found {} packages".format(len(packages)))
        for i, package in enumerate(packages):
            print("{}: local-name: {}, url: {}".format(i, package[0], package[1]))
    return packages


def downloadTarball(package, outputdir):
    thetarfile = package[1]
    localname = package[0]
    tempdir = "/tmp/ros_temp"
    if not os.path.exists(tempdir):
        os.mkdir(tempdir)
    outputpackage = os.path.join(outputdir, localname)
    if os.path.isdir(outputpackage):
        print("{} already downloaded.".format(outputpackage))
        return
    print('Downloading {}'.format(thetarfile))
    try:
        ftpstream = urllib.request.urlopen(thetarfile)
        thetarfile = tarfile.open(fileobj=ftpstream, mode="r|gz")
        thetarfile.extractall(path=tempdir)
        thetarfile.close()
    except Exception as e:
        print("Error: failed to download {} with error {}".format(thetarfile, e))
        shutil.rmtree(tempdir)
        return
    count = 0
    for basename in os.listdir(tempdir):
        if os.path.isdir(os.path.join(tempdir, basename)):
            shutil.move(os.path.join(tempdir, basename), outputpackage)
            count += 1
    if count != 1:
        raise RuntimeError("Expected exactly one directory in tar file")
    shutil.rmtree(tempdir)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: download_ros_tar.py <rosinstallfile> <outputdir>")
        sys.exit(1)
    rosinsallfile = sys.argv[1]
    outputdir = sys.argv[2]
    packages = loadRosPackageList(rosinsallfile)
    for package in packages:
        downloadTarball(package, outputdir)
