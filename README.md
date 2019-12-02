## Quickstart
### Software
On a fresh installation of Raspbian [Buster Lite](https://www.raspberrypi.org/downloads/) on a Raspberry Pi, run the following commands to install everything you need to run the Nido thermostat:

```bash
cd ~
mkdir nido
cd nido
curl -fsSL get-nido.moveolabs.com | source /dev/stdin
```

For the extra cautious, you can verify the checksum of the install script, below, and the download domain [ownership](https://keybase.io/alexmensch).

```bash
shasum -a 256 get-nido.sh 
ff1e30736203abfb22656b5d23a1b7984b0915e75b810dd09c11f5dfbc642dfb  get-nido.sh
```

Once Nido is up and running, you can add it as a new accessory in the Apple Home app using the default code `94812494` or by scanning the QR code in the Homebridge startup logs. Make sure your Apple device is on the same network as the Raspberry Pi.

### Hardware
Aside from a Raspberry Pi, you'll need the custom Nido PCB and the necessary components. Once this is built, it plugs straight into the Raspberry Pi's GPIO header.

Details can be found here: [alexmensch/nido-pcb](https://github.com/alexmensch/nido-pcb)

## More information
A full write-up on the project background, hardware design, software design, and installation guide can be found on my blog.
