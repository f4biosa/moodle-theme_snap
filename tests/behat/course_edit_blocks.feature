# This file is part of Moodle - http://moodle.org/
#
# Moodle is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Moodle is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Moodle.  If not, see <http://www.gnu.org/licenses/>.
#
# Tests course edting mode.
#
# @package    theme_snap
# @copyright  Copyright (c) 2015 Open LMS. (https://www.openlms.net)
# @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later

@theme @theme_snap @theme_snap_course
Feature: When the moodle theme is set to Snap, teachers only see block edit controls when in edit mode.

  Background:
    Given the following "courses" exist:
      | fullname | shortname | category | format |
      | Course 1 | C1        | 0        | topics |
      | Course 2 | C2        | 0        | weeks  |
    And the following "users" exist:
      | username | firstname | lastname | email |
      | teacher1 | Teacher   | 1        | teacher1@example.com |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | admin    | C1     | editingteacher |
      | teacher1 | C1     | editingteacher |
      | teacher1 | C2     | editingteacher |

  @javascript
  Scenario: In read mode on a topics course, teacher clicks edit blocks and can edit blocks.
    Given I skip because "It will be reviewed on the ticket INT-19928"
    Given the following "activities" exist:
      | activity | course | idnumber | name             | intro                         | section |
      | assign   | C1     | assign1  | Test assignment1 | Test assignment description 1 | 1       |
    And I log in as "teacher1"
    And I am on the course main page for "C1"
    And I follow "Topic 1"
    Then "#section-1" "css_element" should exist
    And ".block_news_items a.toggle-display" "css_element" should not exist
    And I should see "Test assignment1" in the "#section-1" "css_element"
    And I follow "Course Dashboard"
    And I follow "Edit blocks"
    Then course page should be in edit mode

    # edit mode persists if course accessed directly via menu
    # (this is basically to check it works without the &notifyeditingon parameter
    Given I am on the course main page for "C1"
    Then course page should be in edit mode

    # Edit mode should persist even if there are iframes in a section summary.
    # First add a section with an iframe which points to the host root.
    And I follow "Turn editing off"
    And I follow "Topic 1"
    And I click on "#section-1 .edit-summary" "css_element"
    And I set the section summary to "<iframe src=\"/\"></iframe>"
    And I press "Save changes"
    And I follow "Course Dashboard"
    And I follow "Edit blocks"
    Then course page should be in edit mode
    # Reload the course page. We should still be in editing mode.
    Given I am on the course main page for "C1"
    Then course page should be in edit mode

    # edit mode does not persist between courses
    Given I am on the course main page for "C2"
    And I follow "Course Dashboard"
    Then I should see "Edit blocks"

  @javascript
  Scenario: If edit mode is on for a course, it should not carry over to site homepage
    Given I skip because "It will be reviewed on the ticket INT-19928"
    Given I log in as "admin"
    And I am on the course main page for "C1"
    And I follow "Course Dashboard"
    And I follow "Edit blocks"
    When I am on site homepage
    Then I should not see "Change site name"
    Then I should not see "Add a block"

  @javascript
  Scenario: If edit mode is on for site homepage, it should not carry over to courses
    Given I log in as "admin"
    And I am on site homepage
    And I click on "#admin-menu-trigger" "css_element"
    And I follow "Turn editing on"
    When I am on the course main page for "C1"
    And I follow "Course Dashboard"
    Then I should see "Edit blocks"
