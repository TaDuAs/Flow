function killapp()
            Simple.obsoleteWarning('Simple.App');
    Simple.App.App.terminate();
    cprintf('Error', 'App persistence terminated successfully.\n');
end

