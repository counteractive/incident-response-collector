# incident-response-collector

## Motivation

Counteractive Security needed a simple, reliable, flexible collector of system data to support incident response, threat hunting, digital forensics, and other services.  Our requirements led to changes that were too significant to fork an existing project or request a vendor feature.

There are great open-source tools like [velociraptor](https://www.velocidex.com/) that centralize similar collections, and much of what's done here has been done, or can be done, under other frameworks.  If you need more than batch collections on a small number of systems creating a set of plain text output files, we encourage you to explore other options.

## Design Priorities

1. Free (like beer and, when possible, speech)
1. Human-readable output
1. Machine-readable output
1. Flexible (customizable, configurable)
1. Fast
1. Defensible (from a forensic perspective)
1. Extensible
1. Maintainable
1. Well-documented

> Order of Volatility: The order in which volatile data should be recovered from various storage locations and devices following a security incident. Data should be gathered in order from most volatile to least volatile, as listed below:
>
>   1. CPU registers, CPU cache
>   1. Router Table, ARP Cache, Process Table
>   1. Temporary File Systems
>   1. Disk
>   1. Remote Logging and monitoring data
>   1. physical configuration, network topology
>   1. Archival Media
>
> _Source: CompTIA Security+_

## Modules

Modules and their results are organized by type (and thus volatility), rather than by "category" or "use," as many are multi-use.

**We create new modules when we want to be able to turn a collection on or off separately.** There are no hard-and-fast rules beyond that - be pragmatic. Sometimes it's simply a matter of the time it takes for a certain module to complete.  "Parent" and "Children" modules are simply a naming convention at this point.

* memory
  * [x] memory-image
  * [x] memory-artifacts
    * [x] hiberfil
    * [x] pagefile
    * [x] minidumps
    * [ ] app dumps
* [ ] processed-volatile (processed info from memory we can pull quickly even if we don't get full memory image)
  * [x] network
    * [x] connections
    * [x] dns cache
    * [x] arp cache
    * [x] routing table
  * [x] process
  * [ ] other (TODO)
    * [ ] sessions
    * [ ] in-memory registry
    * [ ] in-memory configuration (hostname, ver, etc.)
* [x] filesystem (metadata, ntfs-only for now)
  * [x] mft
  * [x] usnjrnl
  * [x] logfile
* [x] files (raw, unparsed)
  * [x] evtx
  * [x] registry hives
  * [x] /etc/hosts
  * [x] prefetch (raw)
  * [x] amcache
  * [x] task files (raw)
* [ ] processed-persistent (processed info from disk we can pull quickly even if we don't get full disk image)
  * [x] system metadata (winaudit)
  * [x] autoruns
  * [x] browsing history and cache
  * [x] activity
  * [x] dir walks
  * [ ] file hashing
  * [x] prefetch (parsed)
  * [ ] usb device history
  * [ ] jump lists
* [ ] scans (checking for specific IOCs)
  * [ ] hash checks
  * [ ] yara scans
  * [ ] bulk_extractor on disk and/or memory
* [ ] full disk (since this is rare, slow, persistent, and can fail often, put it last)

## Views

Once data is collected, the "uses" of the data can be views on the result files, for automated or human analysis.  More to follow on how these are to be implemented.

## Collector Comparison

Our incident response collector compares to similar projects as follows:

TODO

## Contributing

* Modules must follow the template under [`template/module-name`](template/module-name)
* internal ("private") variables must be lower-case, prepended with an underscore (`set _variable=value`)
* global variables, those that may be overridden from the batch call or are shared between modules, must be all uppercase

## Inspiration

* ir-rescue (coding style, thoroughness (e.g., vss), tools)
* BrimorLabs Live Response Collection (modularity, reliability, speed)
