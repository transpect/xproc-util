# virustotal

Send local files to Virus Total and get a Schematron report

## Description

This XProc step use the Total Virus API to upload and scan local 
files. Scan reports are retrieved with `p:http-request` and 
validated with Schematron.

## Requirements

* Requires a Virus Total API key. You can obtain an API key by register an user account at https://www.virustotal.com/. Later you can receive your API key here: https://www.virustotal.com/de/user/MYUSERNAME/apikey/
* XML Calabash including transparent JSON extension enabled (add this on command line: `-Xtransparent-json -Xjson-flavor=marklogic`). A pipeline can test whether the extension is enabled or not with the p:system-property function using `cx:transparent-json`.



## Ports

* `result` the JSON-XML-representation of the scan report
* `report` a Schematron SVRL document that contain one or more svrl:failed-assert 
elements for each scanner and successful virus detection

## Options

* `api-key` your personal VirusTotal API key
* `href` the file to be checked
* `scan-url` URL for VirusTotal-Scan-Request, default: `https://www.virustotal.com/vtapi/v2/file/scan`
* `report-url` URL for VirusTotal-Scan-Request, default: `https://www.virustotal.com/vtapi/v2/file/report`

