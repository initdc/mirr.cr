# mirr.cr

Setting mirrors for your OS and software.

## Installation

TODO: Write installation instructions here

## Usage

```sh
Usage: mirr ubuntu <command>

Example:
  mirr ubuntu change CN

Command:
  help                     Show this help message
  list                     print all ubuntu mirror locations
  choose                   Asking to choose a server from tcping results
  fastest                  Use the fastest server from tcping results
  change [location]        Change source server to location mirror
  mirror [location]        Use mirror:// protocol with your location
  custom <url>             Use custom server with your url
  restore                  Restore sources.list from backup 
  default                  Recover with default sources.list
  enable-src               Enable deb-src
  disable-src              Disable deb-src
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/mirr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [initdc](https://github.com/your-github-user) - creator and maintainer
