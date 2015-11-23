module CoreExtensions
  module Proc
    module Inspect
      def self.included(base)
        base.class_eval do
          def inspect
            ProcSource.new(self).inspect
          end
        end
      end
    end
  end
end
