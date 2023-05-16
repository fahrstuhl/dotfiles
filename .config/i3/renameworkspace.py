#!/usr/bin/env python
# -*- coding: utf-8 -*-
# renameworkspace.py - Renaming i3 workspaces with https://github.com/acrisci/i3ipc-python while keeping the <number>: <letter> prefix for keyboard navigation.
# Written in 2017 by Fahrstuhl

# To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide. This software is distributed without any warranty.

# You should have received a copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

import i3
import re

class WorkspaceRenamer(object):
    
    prefixRegex = re.compile('\d+:\S+')

    def __init__(self):
        pass

    def findFocusedWorkspace(self):
        workspaces = i3.get_workspaces()
        for workspace in workspaces:
            if workspace["focused"] == True:
                return workspace

    def getWorkspacePrefix(self):
        workspace = self.findFocusedWorkspace()
        oldname = workspace["name"]
        prefix = self.prefixRegex.match(oldname)
        if prefix is None:
            raise LookupError("No workspace name found")
        return prefix.group(0)

    def interactiveRenameCurrentWorkspace(self):
        prefix = self.getWorkspacePrefix()
        renameCommand = 'rename workspace to "{} %s"'.format(prefix)
        inputCommand = """exec i3-input -F '{}' -P "Rename workspace to: {} " """.format(renameCommand, prefix)
        print(renameCommand)
        print(inputCommand)
        i3.command(inputCommand)

def main():
    renamer = WorkspaceRenamer()
    renamer.interactiveRenameCurrentWorkspace()

if __name__ == "__main__":
    main()

