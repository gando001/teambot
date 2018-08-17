module SlackRubyBot
  module Commands
    class Help < Base
      def self.call(client, data, match)
        command = match[:expression]

        text = command.present? ? Support::Help.instance.command_full_desc(command) : general_text

        client.say(channel: data.channel, text: text, gif: 'help')
      end

      class << self
        private

        def general_text
          bot_desc = Support::Help.instance.bot_desc_and_commands
          other_commands_descs = Support::Help.instance.other_commands_descs

          [bot_desc, other_commands_descs].join("\n")
        end
      end
    end
  end
end