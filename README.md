# Setup
## Set environment variables
  - EVERNOTE_CONSUMER_KEY: Set your evernote consumer key
  - EVERNOTE_CONSUMER_SECRET: Set your evernote consumer secret key
    - More about Evernote API: http://dev.evernote.com/documentation/cloud/
  - EVERNOTE_SITE:
      - For sandbox: https://sandbox.evernote.com
      - For production: https://www.evernote.com

##
    export EVERNOTE_CONSUMER_KEY="XXXXX"
    export EVERNOTE_CONSUMER_SECRET="XXXXX"
    export EVERNOTE_SITE="https://sandbox.evernote.com"

## Set up database
    rake db:setup

# Run
## Run thin server
    thin start
