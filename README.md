# Jira Script
## Introduction
jira-script is a Ruby based DSL for automating the process of creating and updating
many Jira issues at once.

## Installation
jira-script is distributed as a gem from RubyGems.org. To install it you can run
```
gem install jira-script
```

## Basic usage
```ruby
require 'jira-script'

Jira.run do
  host 'https://my.jira.host.com'
  api_path 'rest/api/2'
  user 'jsmith'
  password 'letmein'
  project 'TEST'
  verbosity 2
  
  create 'Test story' do
    assignee 'mike'
    labels 'ready-for-dev'
    components 'SOME_COMPONENT'
    description 'As a user I want to ... {{jira markup allowed}}'
    
    subtask 'Implementation' do
      assignee 'mike'
      estimation '5d'
      description 'Implement the story'
    end
    
    subtask 'Code Review' do
      type 'Technical task'
      assignee 'erika'
    end
    
  end
  
  create 'Extra task' do
    parent 'TEST-6'
    description 'We need to do this also'
  end
  
  update 'TEST-3' do
    assignee 'john'
    summary 'Tesk task'
    components 'SOME_COMPONENT', 'SOME_OTHER_COMPONENT'
    labels 'ready-for-dev'
  end
  
end
```

## Commands
### create

Creates a new issue
 ```ruby
create 'summary' do
# ... issue definition ...
end
```
 or
 
```ruby
create 'summary'
``` 
 
When using the latter form the issue will be created with the default type of **Story**

If `parent` is given, than the issue is created as a sub-task of the specified parent.
 The default sub-task type is 'Technical task'.
 
### update

Updates an issue
```ruby
update 'ISSUEKEY-132' do
# ... update definition ...
end
```

The update command requires an **issue key** to be provided as parameter.

The update definition block is mandatory

### subtask
This command can only be used as part of a `create` definition block.

It creates a sub-task for the current issue.
 ```ruby
subtask 'summary' do
# ... definition ...
end
```

The definition block uses the same rules as the ones in place for the `create` command definition block.
`create` inside another `create` can be used as an alias for `subtask`.

## Command parameters
These parameters can be used inside command blocks.

### summary
Specifies the issue summary. It can be used with both `create` and `update`.
```ruby
summary 'Implementation'
```

### description
Specifies the issue description It can be used with both `create` and `update`.
```ruby
create 'some story' do
  description 'Some description'
end
 
```
### parent
Specifies the parent of the issue. It can be used with both `create` and `update`.

```ruby
create 'some story' do
  parent 'TEST-5'
end
```

If won't have any effect when used in a `subtask` command.

### type
Specifies the issue type. It can be used with both `create` and `update`.

For top-level issues, the default issue type is 'Story'.

For sub-tasks, the default issue type is 'Technical task'.
```ruby
update 'TEST-5' do
  type 'Technical task'
end
```

### assignee
Specifies the assignee of the task. It can be used with both `create` and `update`.

```ruby
update 'TEST-5' do
  assignee 'jsmith'
end
```

### estimation
Specifies the original estimation. The Jira format can be used i.e. "5d 3h 30m".

It can be used with both `create` and `update`.

```ruby
update 'TEST-5' do
  estimation '5h'
end
```

### remaining
Specifies the remaining time. The Jira format can be used i.e. "5d 3h 30m".

It can be used with both `create` and `update`.
```ruby
update 'TEST-5' do
  remaining '5h'
end
```

### components
Sets the list of components. It can be used with both `create` and `update`.

```ruby
update 'TEST-5' do
  components 'COMPONENT-X', 'COMPONENT-Y'
end
```

### labels
Sets the list of labels. It can be used with both `create` and `update`.

```ruby
update 'TEST-5' do
  labels 'LABEL-X', 'LABEL-Y'
end
```

### verbosity
Valid values are 
- 0 - No output is performed.
- 1 - Success messages are displayed for `create`, `update` and `subtask` commands
- 2 - Success messages are displayed for `create`, `update` and `subtask` commands and also json payloads that are sent to Jira are also displayed.


### quite
This is an alias for `verbosity 0` 