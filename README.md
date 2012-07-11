# Setup
## Set environment variables
  - EVERNOTE_CONSUMER_KEY: Set your evernote consumer key
  - EVERNOTE_CONSUMER_SECRET: Set your evernote consumer secret key
  - EVERNOTE_SITE:
      - For sandbox: https://sandbox.evernote.com
      - For production: https://www.evernote.com
## Set up database
    rake db:setup

# Run
## Run thin server
    thin start
