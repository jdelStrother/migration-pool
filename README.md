# README

* Check out this repository

* `bundle install`

* `bin/rails db:reset`

* `bin/rails server`, then visit 127.0.0.1:3000

* Check out `main~1` (resulting in a change in db/migrate), reload 127.0.0.1:3000


This results in ActiveRecord::ConnectionNotEstablished - "No connection pool for 'ApplicationRecord'" found from the migration-checker middleware:

```
activerecord (6.1.5) lib/active_record/connection_adapters/abstract/connection_pool.rb:1125:in `retrieve_connection'
activerecord (6.1.5) lib/active_record/connection_handling.rb:327:in `retrieve_connection'
activerecord (6.1.5) lib/active_record/connection_handling.rb:283:in `connection'
activerecord (6.1.5) lib/active_record/model_schema.rb:380:in `table_exists?'
activerecord (6.1.5) lib/active_record/migration.rb:1108:in `get_all_versions'
activerecord (6.1.5) lib/active_record/migration.rb:1121:in `needs_migration?'
activerecord (6.1.5) lib/active_record/migration.rb:625:in `check_pending!'
activerecord (6.1.5) lib/active_record/migration.rb:590:in `block (2 levels) in call'
activesupport (6.1.5) lib/active_support/evented_file_update_checker.rb:59:in `execute'
activesupport (6.1.5) lib/active_support/evented_file_update_checker.rb:65:in `execute_if_updated'
activerecord (6.1.5) lib/active_record/migration.rb:597:in `block in call'
activerecord (6.1.5) lib/active_record/migration.rb:587:in `synchronize'
activerecord (6.1.5) lib/active_record/migration.rb:587:in `call'
actionpack (6.1.5) lib/action_dispatch/middleware/callbacks.rb:27:in `block in call'
activesupport (6.1.5) lib/active_support/callbacks.rb:98:in `run_callbacks'
actionpack (6.1.5) lib/action_dispatch/middleware/callbacks.rb:26:in `call'
actionpack (6.1.5) lib/action_dispatch/middleware/executor.rb:14:in `call'
actionpack (6.1.5) lib/action_dispatch/middleware/actionable_exceptions.rb:18:in `call'
actionpack (6.1.5) lib/action_dispatch/middleware/debug_exceptions.rb:29:in `call'
actionpack (6.1.5) lib/action_dispatch/middleware/show_exceptions.rb:33:in `call'
railties (6.1.5) lib/rails/rack/logger.rb:37:in `call_app'
railties (6.1.5) lib/rails/rack/logger.rb:26:in `block in call'
activesupport (6.1.5) lib/active_support/tagged_logging.rb:99:in `block in tagged'
activesupport (6.1.5) lib/active_support/tagged_logging.rb:37:in `tagged'
activesupport (6.1.5) lib/active_support/tagged_logging.rb:99:in `tagged'
railties (6.1.5) lib/rails/rack/logger.rb:26:in `call'
actionpack (6.1.5) lib/action_dispatch/middleware/remote_ip.rb:81:in `call'
actionpack (6.1.5) lib/action_dispatch/middleware/request_id.rb:26:in `call'
rack (2.2.3) lib/rack/method_override.rb:24:in `call'
rack (2.2.3) lib/rack/runtime.rb:22:in `call'
activesupport (6.1.5) lib/active_support/cache/strategy/local_cache_middleware.rb:29:in `call'
actionpack (6.1.5) lib/action_dispatch/middleware/executor.rb:14:in `call'
actionpack (6.1.5) lib/action_dispatch/middleware/static.rb:24:in `call'
rack (2.2.3) lib/rack/sendfile.rb:110:in `call'
actionpack (6.1.5) lib/action_dispatch/middleware/host_authorization.rb:148:in `call'
railties (6.1.5) lib/rails/engine.rb:539:in `call'
puma (5.4.0) lib/puma/configuration.rb:249:in `call'
puma (5.4.0) lib/puma/request.rb:77:in `block in handle_request'
puma (5.4.0) lib/puma/thread_pool.rb:340:in `with_force_shutdown'
puma (5.4.0) lib/puma/request.rb:76:in `handle_request'
puma (5.4.0) lib/puma/server.rb:440:in `process_client'
puma (5.4.0) lib/puma/thread_pool.rb:147:in `block in spawn_thread'
```

The problem appears to be that the migration connection has a reference to ApplicationRecord, but it's a old reference from before class reloading kicked in, so `self == ApplicationRecord` is no longer true, resulting in connection_specification_name returning `"ApplicationRecord"` rather than the expected `"ActiveRecord::Base"`

One potential fix that seems to work for me is to reimplement `ActiveRecord::Base.primary_class?` like so:

```
def primary_class?
  self == ActiveRecord::Base || self.name == "ApplicationRecord"
end
```
