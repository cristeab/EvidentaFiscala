# FiscalRecords

Application used to keep fiscal records in CSV files.
The main reason for writing this application is to have an improved method
to keep fiscal records than normal CSV files for a self-employed person.

Supported languages: Romanian, English, French.

The following features are supported:

* record income and generate automaticaly the registration numbers for the receipts
(generated separately)

* record expenses

* show graphically the monthly gross income, expenses and the net income. There are 2
possible graphical representations: with lines and with bars.

* generate automatically a fiscal records register in ODF format with the total gross income and
expenses

* create a new ledger with the expected columns (one per year is needed usually)

* backup the ledger in a local git repository (the git repository must be manually created)

# Screenshots

![table](screenshots/table.png?raw=true "Records Table")

![graph](screenshots/graph.png?raw=true "Records Graph")

![general](screenshots/settings_general.png?raw=true "Settings - General Tab")

![general](screenshots/settings_visible.png?raw=true "Settings - Visible Columns Tab")

![general](screenshots/settings_backup.png?raw=true "Settings - Backup Tab")