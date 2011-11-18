require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      # ActiveRecord's mechanism for disabling referential integrity
      # on PostgreSQL requires a database superuser account if you run
      # it on a database that has actual FKs in it.
      #
      # This method does not work if a particular FK constraint is not
      # declared deferrable. We'll see if that's a practical issue for
      # SP.
      def disable_referential_integrity #:nodoc:
        if supports_disable_referential_integrity?() then
          transaction do
            execute('SET CONSTRAINTS ALL DEFERRED')
            yield
            execute('SET CONSTRAINTS ALL IMMEDIATE')
          end
        else
          yield
        end
      end
    end
  end
end
