"""
Constants that may be used in multiple packages
"""
try:
    from collections import OrderedDict
except ImportError, exc:
    # Python 2.6.
    from ordereddict import OrderedDict

from django.utils.timezone import utc
from datetime import datetime

# Message type selector.
LOCAL_MESSAGE, EMAIL_MESSAGE, NO_MESSAGES, DEFAULT_MESSAGES, ALL_MESSAGES = range(5)

MESSAGING_MAP = OrderedDict([
    (DEFAULT_MESSAGES, "default",),
    (LOCAL_MESSAGE, "local messages",),
    (EMAIL_MESSAGE, "email",),
    (ALL_MESSAGES, "email for every new thread",),
])

MESSAGING_TYPE_CHOICES = MESSAGING_MAP.items()

# Connects a user sort dropdown word to a data model field.
USER_SORT_MAP = OrderedDict([
    ("recent visit", "-profile__last_login"),
    ("reputation", "-score"),
    ("date joined", "profile__date_joined"),
    #("number of posts", "-score"),
    ("activity level", "-activity"),
])

# These are the fields rendered in the user sort order drop down.
USER_SORT_FIELDS = USER_SORT_MAP.keys()
USER_SORT_DEFAULT = USER_SORT_FIELDS[0]

USER_SORT_INVALID_MSG = "Invalid sort parameter received"

# Connects a post sort dropdown word to a data model field.
POST_SORT_MAP = OrderedDict([
    ("New answers", "-lastedit_date"),
    ("Views", "-view_count"),
    ("Followers", "-subs_count"),
    ("Answers", "-reply_count"),
    ("Bookmarks", "-book_count"),
    ("Votes", "-vote_count"),
    ("Rank", "-rank"),
    ("Creation", "-creation_date"),
])

# These are the fields rendered in the post sort order drop down.
POST_SORT_FIELDS = POST_SORT_MAP.keys()
POST_SORT_DEFAULT = POST_SORT_FIELDS[0]

POST_SORT_INVALID_MSG = "Invalid sort parameter received"

# Connects a word to a number of days
POST_LIMIT_MAP = OrderedDict([
    ("All time", 0),
    ("Today", 1),
    ("This week", 7),
    ("This month", 30),
    ("This year", 365),

])

# These are the fields rendered in the time limit drop down.
POST_LIMIT_FIELDS = POST_LIMIT_MAP.keys()
POST_LIMIT_DEFAULT = POST_LIMIT_FIELDS[0]
POST_LIMIT_INVALID_MSG = "Invalid limit parameter received"

POST_ANSWERED_MAP = ["all", "unanswered"]
POST_ANSWERED_DEFAULT = POST_ANSWERED_MAP[0]
POST_ANSWERED_INVALID_MSG = "'answered' must be 'all' or 'unanswered'"

def now():
    return datetime.utcnow().replace(tzinfo=utc)


