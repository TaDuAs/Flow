function id = guid()
% generates a pseudo random unique id
    id = char(java.util.UUID.randomUUID());
end

