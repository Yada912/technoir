extends Node
## Soft BGM + SFX buses. Procedural fallback tones if assets missing.

const BUS_BGM := "BGM"
const BUS_SFX := "SFX"

var _bgm_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _streams: Dictionary = {}
var _bgm_stream: AudioStream


func _ready() -> void:
	_ensure_buses()
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = BUS_BGM
	add_child(_bgm_player)
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = BUS_SFX
	add_child(_sfx_player)
	_load_streams()
	apply_volumes()
	play_bgm("bgm_soft")


func _ensure_buses() -> void:
	if AudioServer.get_bus_index(BUS_BGM) == -1:
		AudioServer.add_bus()
		var idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, BUS_BGM)
		AudioServer.set_bus_send(idx, "Master")
	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus()
		var idx2 := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx2, BUS_SFX)
		AudioServer.set_bus_send(idx2, "Master")


func _load_streams() -> void:
	_streams["ui_tap"] = _tone(880.0, 0.04, 0.15)
	_streams["screw_turn"] = _tone(220.0, 0.18, 0.2)
	_streams["part_snap_out"] = _noise_burst(0.12, 0.25)
	_streams["part_snap_in"] = _tone(520.0, 0.08, 0.22)
	_streams["success_chime"] = _chime([523.25, 659.25, 783.99], 0.16)
	_streams["cassette_loop"] = _tone(196.0, 1.2, 0.12)
	_bgm_stream = _soft_pad()
	_streams["bgm_soft"] = _bgm_stream
	# Prefer disk assets when present
	_try_file("bgm_soft", "res://assets/audio/bgm_soft.ogg")
	_try_file("ui_tap", "res://assets/audio/ui_tap.wav")
	_try_file("screw_turn", "res://assets/audio/screw_turn.wav")
	_try_file("part_snap_out", "res://assets/audio/part_snap_out.wav")
	_try_file("part_snap_in", "res://assets/audio/part_snap_in.wav")
	_try_file("success_chime", "res://assets/audio/success_chime.wav")
	_try_file("cassette_loop", "res://assets/audio/cassette_loop.wav")


func _try_file(key: String, path: String) -> void:
	if ResourceLoader.exists(path):
		var res: Resource = load(path)
		if res is AudioStream:
			_streams[key] = res
			if key == "bgm_soft":
				_bgm_stream = res


func apply_volumes() -> void:
	_set_bus_linear(BUS_BGM, Save.bgm_volume)
	_set_bus_linear(BUS_SFX, Save.sfx_volume)


func _set_bus_linear(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	var db := linear_to_db(clampf(linear, 0.0001, 1.0))
	if linear <= 0.001:
		db = -80.0
	AudioServer.set_bus_volume_db(idx, db)


func play_bgm(key: String = "bgm_soft") -> void:
	var stream: AudioStream = _streams.get(key, _bgm_stream)
	if stream == null:
		return
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	_bgm_player.stream = stream
	_bgm_player.play()


func stop_bgm() -> void:
	_bgm_player.stop()


func play_sfx(key: String) -> void:
	if not _streams.has(key):
		return
	_sfx_player.stream = _streams[key]
	_sfx_player.play()


func _tone(freq: float, duration: float, amp: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var frames := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(frames * 2)
	for i in frames:
		var t := float(i) / float(sample_rate)
		var env := 1.0
		var attack := 0.01
		var release := 0.04
		if t < attack:
			env = t / attack
		elif t > duration - release:
			env = maxf(0.0, (duration - t) / release)
		var sample := int(clampf(sin(TAU * freq * t) * amp * env, -1.0, 1.0) * 32767.0)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream


func _noise_burst(duration: float, amp: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var frames := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(frames * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in frames:
		var t := float(i) / float(frames)
		var env := (1.0 - t) * (1.0 - t)
		var sample := int(clampf(rng.randf_range(-1.0, 1.0) * amp * env, -1.0, 1.0) * 32767.0)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream


func _chime(freqs: Array, note_len: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var total := int(sample_rate * note_len * freqs.size())
	var data := PackedByteArray()
	data.resize(total * 2)
	var idx := 0
	for f in freqs:
		var frames := int(sample_rate * note_len)
		for i in frames:
			var t := float(i) / float(sample_rate)
			var env := 1.0 - float(i) / float(frames)
			var sample := int(clampf(sin(TAU * float(f) * t) * 0.22 * env, -1.0, 1.0) * 32767.0)
			data[idx * 2] = sample & 0xFF
			data[idx * 2 + 1] = (sample >> 8) & 0xFF
			idx += 1
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream


func _soft_pad() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 8.0
	var frames := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(frames * 2)
	for i in frames:
		var t := float(i) / float(sample_rate)
		var s := (
			sin(TAU * 110.0 * t) * 0.08
			+ sin(TAU * 164.81 * t) * 0.05
			+ sin(TAU * 220.0 * t) * 0.04
		)
		s *= 0.85 + 0.15 * sin(TAU * 0.15 * t)
		var sample := int(clampf(s, -1.0, 1.0) * 32767.0)
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = frames
	stream.data = data
	return stream
