# About this ProcessWire Setup

**Dockerfile**. Sets up the instance of PHP and Apache in its own container, including the specific dependencies required by ProcessWire. The dependencies are loaded and configured through a file called `local.ini` which is similar to `php.ini`. See PHP documentation for more info. I am choosing `local.ini` in order to avoid PHP upgrade issues in the future. This is probably unnecessary for a development site, however your future self should be your best friend. I like to think about what possible future problems I can avoid with what we know now.

**docker-compose.yml**. Builds MySQL in its own container and links it with the PHP/Apache container in a common network. It also sets up a folder for your website data in a location on the host (i.e. your laptop computer).

**init.sh**. This is a bash script that sets up `local.ini` (mentioned above) and runs the server. This could also happen within 'docker-compose.yml' however things get complicated when you're trying to create a new directory (i.e. `/conf.d` for the `local.ini` file) inside Docker Compose.

## Setting up your instance of ProcessWire

## Instructions
Clone this repo into your selected folder, run Docker, and enter `docker-compose up`. Please see documentation for Docker Compose for more details. Once **both** containers are up and running, go to `localhost` on your browser and follow the instructions to complete the install.

Once in the ProcessWire install page, you will be prompted to enter information for connecting to the database. It's especially important to get this right when trying to connect with a separate Docker container, but luckily Docker makes it easy for us. More on that below.

### TL;DR
The MySQL database name and hostname are both `db`. MySQL user and password are 'root'. You may change these defitions in the `docker-compose.yml` file.

### The Docker Network

First, let's look at the wrong way to connect to your database, which is nonetheless very educational. From the command line on the host (i.e. your computer), enter:

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

Having seen this approach, don't use it! Why? Every time Docker starts up this network and its containers, it may assign them a different IP address. If you try to connect from your browser, you will see an ugly, fatal error from which there is no escape.

You could recover by finding the correct IP address again as shown above. But because ProcessWire is already installed, you can't go into the install tool because those files were (hopefully) deleted. Instead, go into `site/templates/config.php` and look for this line:

`$config->dbHost = 'xxx.xxx.xxx.xxx'; // Actual IP address is here`

and then replace the old IP address with the current IP address you just pulled up. Exhausting, isn't it?

### The right way to identify your database host

Look into `docker-compose.yml` and find the service that describes our database, like in this snippet:

```
services:
  db:
    image: mysql:latest
```

The name of the service is `db`. Every time Docker starts up the network and its containers, it comes up with an IP address, assigns `db` to it and makes it the hostname. Within this network, `db` resolves to whatever the IP address is. Armed with this knowledge, you can just enter `db` into the hostname field when installing or into `config.php` later on.

When ProcessWire is installed, the line in `site/templates/config.php` should look like this:

`$config->dbHost = 'db'; // That's it!`

Yet another option, by the way, would be to assign a static IP address to your containers and hard code that into the `config.php` file. A solid understanding of Docker networking and general IP networking is highly recommended in this case. Even so, YMMV. The effort might get in the way of any actual web design you might be pursuing.

## Known issues and caveats
* The containers should be set to `restart: always` because otherwise MySQL on occasion may decide to stop working before you get it even set up.
* The setup page may sometimes record your admin username and password, and then promptly lose it. I have no idea why this happens, however it is most definitely a fatal condition unless you go into `phpMyAdmin` and manually change it. See docs for more details.
* This is not tested in any kind of production environment, so don't use it! This is for quickly spinning up a copy of ProcessWire to see what the fuss is all about or build a site for someone. While you're at it, you'll get to learn some of the finer points of configuring a PHP/Apache install.
