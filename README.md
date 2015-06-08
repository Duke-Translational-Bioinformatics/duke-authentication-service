# duke-authentication-service
Authentication Microservice for the [Duke Data Service](https://github.com/Duke-Translational-Bioinformatics/duke-data-service)

### contributing
The master branch of the project is considered the stable, production branch.
All commits should propogate from 'develop' to 'uatest', and then to master
only after UA Testing has approved changes to the code.
Here are steps for new developers to follow:

1. Git clone the project
1. git fetch origin develop
1. git checkout --track origin/develop
1. develop on develop.  As a precaution, you should always create
branches off of develop explicitly, e.g.:
  ```
  $ git branch -b try_foo develop
  ```
You should then merge branches back into devlop. You might consider
deleting the master branch from your local repository.
1. git push/pull (this will push to and pull from develop)
