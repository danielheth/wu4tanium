#!/usr/bin/env python

from pyjenkins import *

class TheBuild(PyJenkinsBuild):
    def run(self):
        # read a remote file
        #version = read_remote_file('the-version.txt')
        # set the display name for this build
        #build.setDisplayName(version)

        # execute the build
        built = False
        built = execute(['cmd', '/c', 'build.bat'])

        # report results always
        #report_tests( '**/test-reports/*-TEST.xml' )

        if not built:
            logger.println('Whoops. It broked.')
            return Result.FAILURE

        # archive artifacts on build success

        # fails if artifact is not present
        archive_artifacts( 'wu4tanium/bin/Release/wu4tanium.zip' )
        

        # return success
        return Result.SUCCESS

register_pybuild( TheBuild() )