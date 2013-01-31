#!/usr/bin/python2
#
# python-mode indent C-c < or C-c >
# python-mode comment/uncomment region M-;

import sys, imaplib, email
from time import sleep

def extract_body(payload):
    if isinstance(payload,str):
        return payload
    else:
        return '\n'.join([extract_body(part.get_payload()) for part in payload])

conn = imaplib.IMAP4_SSL("imap.gmail.com", 993)
conn.login(EMAIL, PASSWD)
conn.select('seisftp')

while True:
    typ, data = conn.search(None, 'FROM', '"autoDRM"', 'UNDELETED')
    # ITERATE THRU ALL MATCHED ITEMS
    for num in data[0].split():
        typ, msg_data = conn.fetch(num, '(RFC822)')
        # GET MSG DATA
        for response_part in msg_data:
            if isinstance(response_part, tuple):
                msg = email.message_from_string(response_part[1])
                payload=msg.get_payload()
                body=extract_body(payload)
                lines = body.split('\n')
                for line in lines:
                    if "TITLE EVENT" in line:
                        fields = line.split()
                        sys.stdout.write(fields[3] + "\n")
                        sys.stdout.flush()
        # DELETE MSG
        typ, response = conn.store(num, '+FLAGS', r'\Deleted')
    conn.expunge()
    sleep(20)

# Prob Never Get here.
try:
    conn.close()
except:
    pass
conn.logout()
