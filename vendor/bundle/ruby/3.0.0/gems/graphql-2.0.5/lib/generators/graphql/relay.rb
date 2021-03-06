# frozen_string_literal: true
module Graphql
  module Generators
    module Relay
      def install_relay
        # Add Node, `node(id:)`, and `nodes(ids:)`
        template("node_type.erb", "#{options[:directory]}/types/node_type.rb")
        in_root do
          fields = "    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`\n    include GraphQL::Types::Relay::HasNodeField\n    include GraphQL::Types::Relay::HasNodesField\n\n"
          inject_into_file "#{options[:directory]}/types/query_type.rb", fields, after: /class .*QueryType\s*<\s*[^\s]+?\n/m, force: false
        end

        # Add connections and edges
        template("base_connection.erb", "#{options[:directory]}/types/base_connection.rb")
        template("base_edge.erb", "#{options[:directory]}/types/base_edge.rb")
        connectionable_type_files = {
          "#{options[:directory]}/types/base_object.rb" => /class .*BaseObject\s*<\s*[^\s]+?\n/m,
          "#{options[:directory]}/types/base_union.rb" =>  /class .*BaseUnion\s*<\s*[^\s]+?\n/m,
          "#{options[:directory]}/types/base_interface.rb" => /include GraphQL::Schema::Interface\n/m,
        }
        in_root do
          connectionable_type_files.each do |type_class_file, sentinel|
            inject_into_file type_class_file, "    connection_type_class(Types::BaseConnection)\n", after: sentinel, force: false
            inject_into_file type_class_file, "    edge_type_class(Types::BaseEdge)\n", after: sentinel, force: false
          end
        end

        # Add object ID hooks & connection plugin
        schema_code = <<-RUBY

  # Relay-style Object Identification:

  # Return a string UUID for `object`
  def self.id_from_object(object, type_definition, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    object_id = object.to_global_id.to_s
    # Remove this redundant prefix to make IDs shorter:
    object_id = object_id.sub("gid://\#{GlobalID.app}/", "")
    encoded_id = Base64.urlsafe_encode64(object_id)
    # Remove the "=" padding
    encoded_id = encoded_id.sub(/=+/, "")
    # Add a type hint
    type_hint = type_definition.graphql_name.first
    "\#{type_hint}_\#{encoded_id}"
  end

  # Given a string UUID, find the object
  def self.object_from_id(encoded_id_with_hint, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    # Split off the type hint
    _type_hint, encoded_id = encoded_id_with_hint.split("_", 2)
    # Decode the ID
    id = Base64.urlsafe_decode64(encoded_id)
    # Rebuild it for Rails then find the object:
    full_global_id = "gid://\#{GlobalID.app}/\#{id}"
    GlobalID::Locator.locate(full_global_id)
  end
RUBY
        inject_into_file schema_file_path, schema_code, before: /^end\n/m, force: false
      end
    end
  end
end
