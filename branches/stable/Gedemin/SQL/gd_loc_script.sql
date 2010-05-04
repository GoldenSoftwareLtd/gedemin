select * from at_relations where not relationname containing 'usr$' and
not relationname containing 'rdb$'

select * from at_fields where not fieldname containing 'usr$' and
not fieldname containing 'rdb$'

select * from at_relation_fields where not relationname containing 'usr$' and
not relationname containing 'rdb$' and not fieldname containing 'usr$'