# About dsstatus #

`dsstatus` checks the status of all DirectoryService nodes on a Mac OS X system, and exits with a non-zero status if any are inaccessible. This is a command-line analog of the "Network Accounts Available" view at the login window. It is intended to let you easily script tasks that depend on whether or not a machine has connectivity to directory servers.

## System Requirements ##
`dsstatus` requires Mac OS X 10.6, due to the use of the Cocoa `OpenDirectory.framework`.

## Usage Example ##
    # When all nodes are available

    $ dsstatus
    $ echo $?
    0

    $ dsstatus -v
    Waiting for network...
    Network ready.
    Checking /BSD/local...
    Checking /Local/Default...
    Checking /LDAPv3/server.example.com...
    All DirectoryService nodes are available.


    # If a node is unavailable

    $ dsstatus
    $ echo $?
    208

    $ dsstatus -v
    Waiting for network...
    Network ready.
    Checking /Active Directory/All Domains...
    Unable to open Directory node with name /Active Directory/All Domains.

## License ##
Copyright (c) 2010 Ben Gollmer.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.