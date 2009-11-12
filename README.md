Wheneva
=======

Wheneva is a multi-tenant personal appointment scheduling app built on Ruby on
Rails. It was the winning entry in the [MyGOSSCON 2009][mygosscon] [24-Hour
OSS Webdev Challenge][24h].

True to the contest, this app was originally built in 24 hours. So, please
excuse the odd commit messages towards the end of the 24 hours. Brains were
sufficiently fried by then.

Features
--------
* Accounts are hosted at their own subdomain
* Opinionated scheduler: your visitors don't get to choose the exact time, the
  app gives you a list of earliest timeslots for the next one week
* Assistant account to confirm or reschedule appointment requests (requirement
  of contest)
* Owner account to view confirmed appointments for the next week
* Per appointment status page to track appointment request status
* Emails when appointment status changes

Requirements
------------
* `uuidtools` gem

Get Involved
------------
* Forking [the project][repo]
* Committing patches (preferably as topic branches)
* Sending Kamal a merge request
* Submitting [bug reports][bugs]

We'll merge and push it to [http://wheneva.com][site]

License
-------
This app is released under the MIT License. See `MIT-LICENSE`.

Authors
-------
* Kamal Fariz Mahyuddin
* Arzumy MD
* Chan Kai Loon

[repo]: http://github.com/bitfluent/wheneva
[bugs]: http://github.com/bitfluent/wheneva/issues
[mygosscon]: http://mygosscon.oscc.org.my/2009/
[site]: http://wheneva.com
[24h]: http://mygosscon.oscc.org.my/2009/24h-oss-webdev-contest/
