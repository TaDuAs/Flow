classdef (Abstract) IMessagingMediator < handle
    methods (Abstract)
        % Registers a message listener, and returns the mvvm.MessageListener object.
        % To stop listening, delete the listener object.
        listener = register(this, messageId, messageHandler);
        
        % Unregisters a message listener.
        % this method should actually be used ONLY by the mvvm.MessageListener
        unregister(this, messageId, listener);
        
        % Fires all listeners to a specific message event
        send(this, message);
        
        % Clears all message listeners registered to the messaging mediator
        clear(this);
    end
end

