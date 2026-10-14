class_name MeshFactory
extends RefCounted
## Procedural soft-styled meshes for demo objects (Compatibility-friendly).


static func make_part(mesh_id: String) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	match mesh_id:
		"cassette_body":
			var box := BoxMesh.new()
			box.size = Vector3(0.42, 0.14, 0.26)
			mi.mesh = box
			mat.albedo_color = Color("2B2B2B")
			mat.metallic = 0.35
			mat.roughness = 0.45
		"cassette_door":
			var door := BoxMesh.new()
			door.size = Vector3(0.34, 0.02, 0.18)
			mi.mesh = door
			mat.albedo_color = Color("3A3A3A")
			mat.metallic = 0.2
		"battery":
			var bat := BoxMesh.new()
			bat.size = Vector3(0.16, 0.05, 0.08)
			mi.mesh = bat
			mat.albedo_color = Color("C4A35A")
			mat.metallic = 0.6
		"fan_base":
			var cyl := CylinderMesh.new()
			cyl.top_radius = 0.12
			cyl.bottom_radius = 0.16
			cyl.height = 0.18
			mi.mesh = cyl
			mat.albedo_color = Color("1E1E1E")
			mat.metallic = 0.4
		"fan_grille":
			var torus := TorusMesh.new()
			torus.inner_radius = 0.11
			torus.outer_radius = 0.15
			mi.mesh = torus
			mi.rotation_degrees = Vector3(90, 0, 0)
			mat.albedo_color = Color("4A4A4A")
			mat.metallic = 0.55
		"fan_blades":
			var blades := CylinderMesh.new()
			blades.top_radius = 0.12
			blades.bottom_radius = 0.12
			blades.height = 0.02
			mi.mesh = blades
			mi.rotation_degrees = Vector3(90, 0, 0)
			mat.albedo_color = Color("D8D2C8")
			mat.metallic = 0.15
			mat.roughness = 0.7
		"screw":
			var screw := CylinderMesh.new()
			screw.top_radius = 0.015
			screw.bottom_radius = 0.015
			screw.height = 0.04
			mi.mesh = screw
			mat.albedo_color = Color("B0B0B0")
			mat.metallic = 0.85
			mat.roughness = 0.3
		_:
			var fallback := SphereMesh.new()
			fallback.radius = 0.05
			mi.mesh = fallback
			mat.albedo_color = Color("888888")
	mi.material_override = mat
	return mi


static func make_desk(night: bool) -> Node3D:
	var root := Node3D.new()
	root.name = "Desk"
	var top := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.6, 0.08, 0.9)
	top.mesh = box
	top.position = Vector3(0, -0.2, 0)
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color("3E2A1A") if night else Color("8B6A4A")
	wood.roughness = 0.85
	top.material_override = wood
	root.add_child(top)
	if night:
		var lamp := OmniLight3D.new()
		lamp.light_color = TechnoirTheme.WARM_LAMP
		lamp.light_energy = 1.6
		lamp.omni_range = 3.5
		lamp.position = Vector3(0.45, 0.55, 0.2)
		root.add_child(lamp)
		var shade := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0.02
		cone.bottom_radius = 0.12
		cone.height = 0.16
		shade.mesh = cone
		shade.position = Vector3(0.45, 0.5, 0.2)
		var shade_mat := StandardMaterial3D.new()
		shade_mat.albedo_color = Color("E8C9A0")
		shade_mat.emission_enabled = true
		shade_mat.emission = TechnoirTheme.WARM_LAMP
		shade_mat.emission_energy_multiplier = 0.6
		shade.material_override = shade_mat
		root.add_child(shade)
	return root
