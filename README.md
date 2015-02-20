# Redmine Emergya Issue Adjustment Plugin

Several issue/tracker behaviour changes to adjust to Emergya workflows:

* Dates Required: make start date required to save an issue, and due date required to close it.

* Allows tracker selection configuration in settings.

* When an issue is closed, the % done is automatically setted to 100%.

* In Risk trackers, the exposition level is automatically set according to the defined table in the plugin configuration setting.

* Shows alphabetically ordered some Redmine filters list

* In Bill trackers, the total charge is automatically calculated according to invoice and VAT. Anyway, you can chose 'Manual' VAT to edit manually the total charge.

* In BPO trackers, the total charge is automatically calculated according to annual cost and start and due dates.

## Install

1. Follow Redmine {plugin installation instructions}[http://www.redmine.org/projects/redmine/wiki/Plugins#Installing-a-plugin].
2. In _Administration_, _plugins_ you may *optionally* configure the plugin.

## Uninstall

1. Follow Redmine {plugin uninstall instructions}[http://www.redmine.org/projects/redmine/wiki/Plugins#Uninstalling-a-plugin].

## License

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version. See LICENSE.txt for details.

