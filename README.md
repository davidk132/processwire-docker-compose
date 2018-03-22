# About this ProcessWire Setup

**Dockerfile**. Sets up the instance of PHP and Apache in its own container, including the specific dependencies required by ProcessWire. The dependencies are loaded and configured through a file called `local.ini` which is similar to `php.ini`. See PHP documentation for more info. I am choosing `local.ini` in order to avoid PHP upgrade issues in the future. This is probably unnecessary for a development site, however your future self should be your best friend. I like to think about what possible future problems I can avoid with what we know now.

**docker-compose.yml**. Builds MySQL in its own container and links it with the PHP/Apache container in a common network. It also sets up a folder for your website data in a location on the host (i.e. your laptop computer).

**init.sh**. This is a bash script that sets up `local.ini` (mentioned above) and runs the server. This could also happen within 'docker-compose.yml' however things get complicated when you're trying to create a new directory (i.e. `/conf.d` for the `local.ini` file) inside Docker Compose.

## Setting up your instance of ProcessWire

### Instructions
Clone this repo into your selected folder, run Docker, and enter `docker-compose up`. Please see documentation for Docker Compose for more details. Once **both** containers are up and running, go to `localhost` on your browser and follow the instructions to complete the install.

The MySQL database name is `db`. MySQL user and password are 'root'. You may change these defitions in the `docker-compose.yml` file.

Database host: Once in the ProcessWire install page, if 'localhost' doesn't work, go to the command line and type

`docker network ls`

to get the name of the Docker network you're on. In my case it was 'processwire_default'. With this, type

`docker network inspect processwire_default`

or whatever is the name of your network. Scroll to the section that describes your database container and look for `IPv4Address`. Enter that (without the suffix, i.e. '/16') in the database host box on the set up form on the ProcessWire install page.

Sample Docker network list of containers:

```
"Containers": {
       "15d17c5f04161a43ad2eebca343427267714f4ab3aed3f4af2fc93f747f27ca5": {
           "Name": "processwire_web_1",
           "EndpointID": "6502c6996b19e19e804c0f355d3377365fbe67799f5392dd9bc60a7d2e178006",
           "MacAddress": "02:42:ac:16:00:03",
           "IPv4Address": "172.22.0.3/16",
           "IPv6Address": ""
       },
       "ba98722d8dfcc07d81c3246bb44d005dc534c6e72365c6b7520566de30b62348": {
           "Name": "processwire_db_1",
           "EndpointID": "c3207459482ff9261bc947a55ebafd491631a00880054e9dbd2289dbcd0a7a5a",
           "MacAddress": "02:42:ac:16:00:02",
           "IPv4Address": "172.22.0.2/16",
           "IPv6Address": ""
       },
       ...
     }
```

## Known issues and caveats
* The containers should be set to `restart: always` because otherwise MySQL on occasion may decide  to stop working before you get it even set up.
* The setup page may sometimes record your admin username and password, and then promptly lose it. I have no idea why this happens, however it is most definitely a fatal condition unless you go into `phpMyAdmin` and manually change it. See docs for more details.
* This is not tested in any kind of production environment, so don't use it! This is for quickly spinning up a copy of ProcessWire to see what the fuss is all about or build a site for someone. While you're at it, you'll get to learn some of the finer points of configuring a PHP/Apache install.
