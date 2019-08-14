#! /usr/bin/env python3
# cording:utf-8

from apiclient import discovery
from oauth2client import file
from oauth2client import tools
import oauth2client
import httplib2
import argparse
import csv
import sys
import os

BASE = os.path.dirname(os.path.abspath(__file__))

SPREADSHEET_ID_FILE = os.path.normpath(os.path.join(BASE, '../assets/spreadsheet_id.txt'))
OPEN_SPREADSHEET_ID_FILE = open(SPREADSHEET_ID_FILE, 'r')
READ_SPREADSHEET_ID_FILE = OPEN_SPREADSHEET_ID_FILE.read()
SPREADSHEET_ID = READ_SPREADSHEET_ID_FILE.rstrip()
OPEN_SPREADSHEET_ID_FILE.close()
RANGE_NAME = 'A1'
MAJOR_DIMENSION = 'ROWS'

CLIENT_SECRET_FILE = os.path.normpath(os.path.join(BASE, '../assets/client_secret.json'))
CREDENTIAL_FILE = os.path.normpath(os.path.join(BASE, '../assets/credential.json'))
APPLICATION_NAME = 'Write Automatically GoogleSpreadSheet On GCP'

store = oauth2client.file.Storage(CREDENTIAL_FILE)
credentials = store.get()
if not credentials or credentials.invalid:
    SCOPES = 'https://www.googleapis.com/auth/spreadsheets'
    flow = oauth2client.client.flow_from_clientsecrets(CLIENT_SECRET_FILE, SCOPES)
    flow.user_agent = APPLICATION_NAME
    args = '--auth_host_name localhost --logging_level INFO --noauth_local_webserver'
    flags = argparse.ArgumentParser(parents=[oauth2client.tools.argparser]).parse_args(args.split())
    credentials = oauth2client.tools.run_flow(flow, store, flags)

http = credentials.authorize(httplib2.Http())
discoveryUrl = ('https://sheets.googleapis.com/$discovery/rest?' 'version=v4')
service = discovery.build('sheets', 'v4', http=http, discoveryServiceUrl=discoveryUrl)
resource = service.spreadsheets().values()

parser = argparse.ArgumentParser()
parser.add_argument('infile', nargs='?', type=argparse.FileType('r'),
                    default=sys.stdin)
args = parser.parse_args(sys.argv[1:])

r = csv.reader(args.infile)
# read whole csv data
data = list(r)

body = {
    "range": RANGE_NAME,
    "majorDimension": MAJOR_DIMENSION,
    "values": data
}
resource.append(spreadsheetId=SPREADSHEET_ID, range=RANGE_NAME,
                valueInputOption='USER_ENTERED', body=body).execute()

