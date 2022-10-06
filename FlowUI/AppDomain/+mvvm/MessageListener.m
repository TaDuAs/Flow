classdef MessageListener < handle
    properties (Access=private)
        messageHandler function_handle;
        messagingMediator mvvm.MessagingMediator;
        messageId;
    end
    
    methods
        function this = MessageListener(messagingMediator, messageId, messageHandler)
            this.messagingMediator = messagingMediator;
            this.messageHandler = messageHandler;
            this.messageId = messageId;
        end
        
        function fire(this, message)
            this.messageHandler(message);
        end
        
        function delete(this)
            if isvalid(this.messagingMediator)
                this.messagingMediator.unregister(this.messageId, this);
            end
            
            delete@handle(this);
        end
    end
end

