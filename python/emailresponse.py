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


def dataReady(subj, lines):
""" Finds myfile.seed and writes it out
to the terminal on stdout """
    for line in lines:
        fields = line.split()
        for field in fields:
            if 'seed' in field:
                sys.stdout.write(field + "\n")
                sys.stdout.flush()
                return

def dataError(subj, lines):
    """ Sends error message with subject event name
    down standard error """
    for line in lines:
        if 'ERROR_LOG' in line:
            sys.stderr.write('error with ' + subj[6:] + "\n")
            sys.stderr.flush()




EMAIL = 'auto.iris.response@gmail.com'
PASSWD = 'auto iris key'
MAILBOX = 'inbox'

conn = imaplib.IMAP4_SSL("imap.gmail.com", 993)
conn.login(EMAIL, PASSWD)
conn.select(MAILBOX)

while True:
    # Get all emails in MAILBOX FROM autoDRM
    typ, data = conn.search(None, 'FROM', '"autoDRM"', 'unseen')
    # ITERATE THRU ALL MATCHED ITEMS
    for num in data[0].split():
        typ, msg_data = conn.fetch(num, '(RFC822)')
        # GET MSG DATA
        for response_part in msg_data:
            if isinstance(response_part, tuple):
                # Message extraction... see python module email
                msg = email.message_from_string(response_part[1])
                subject = msg['subject']
                payload = msg.get_payload()
                body = extract_body(payload)
                lines = body.split('\n')
                for line in lines:
                    if "FTP_FILE" in line:
                        dataReady(subject, lines)
                        break
                    if 'ERROR_LOG' in line:
                        dataError(subject, lines)
                        break

        # Mark Message as Read
        typ, response = conn.store(num, '+FLAGS', r'\Seen')

    sleep(10)

# Prob Never Get here.
try:
    conn.close()
except:
    pass
conn.logout()
