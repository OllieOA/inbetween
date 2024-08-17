class_name PropertyMoverSpecifier extends Resource

enum SupportedProperties {POSITION, ROTATION, GLOBAL_POSITION, GLOBAL_ROTATION}

@export var property_name: SupportedProperties
@export var sub_components: Array[PropertyMoverValueSpecifier]
