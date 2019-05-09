Feature: Episode reminder
  Scenario: When a new unseen episode is airing today, an email should be send
    Given it is currently 2019-05-08 16:00:00
    Given an empty mailbox
    Given these users:
      | firstname | lastname   | emailaddress          | sendemailnotice |
      | Rick      | Pastoor    | rickpastoor@gmail.com | yes             |
    Given these shows:
      | title           | tvdbid |
      | Game of Thrones | 1      |
    Given these seasons:
      | id  | show | title |
      | 90  | 1    | 1     |
    Given these episodes:
      | show | season  | title            | firstaired | order |
      | 1    | 90      | Winter Is Coming | 2019-05-08 | 1     |
    Given user "rickpastoor@gmail.com" is following show with tvdbid "1"
    And episode reminders are sent
    Then there should be 1 emails sent
    And the subject of the email should be "1 new episode airing today"
