classdef MessagingMediatorSession < handle & mvvm.IMessagingMediator
    %MESSAGEMEDIATORSESSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        ParentMessageMediator mvvm.MessagingMediator;
        Listeners cell;
    end
    
    methods
        function this = MessagingMediatorSession(messageMediator)
            this.ParentMessageMediator = messageMediator;
        end
        
        function listener = register(this, messageId, messageHandler)        
        % Registers a message listener, and returns the mvvm.MessageListener object.
        % To stop listening, delete the listener object.
        
            listener = this.ParentMessageMediator.register(messageId, messageHandler);
            this.Listeners = [this.Listeners, {listener}];
        end
        
        function unregister(this, messageId, listener)
        % Unregisters a message listener.
        % this method should actually be used ONLY by the mvvm.MessageListener
        
            this.ParentMessageMediator.unregister(messageId, listener);
        end
        
        function send(this, message)
        % Fires all listeners to a specific message event
        
            this.ParentMessageMediator.send(message);
        end
        
        function clear(this)
        % Clears all message listeners registered to this session
        
            if ~isvalid(this)
                return;
            end
            
            for i = 1:numel(this.Listeners)
                listener = this.Listeners{i};
                
                if isvalid(listener)
                    delete(listener);
                end
            end
            
            this.Listeners = {};
        end
        
        function delete(this)
            this.clear();
            
            delete@handle(this);
        end
    end
end

