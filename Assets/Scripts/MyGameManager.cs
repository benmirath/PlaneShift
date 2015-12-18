using UnityEngine;
using UnityEngine.EventSystems;
using System.Collections.Generic;
using System;
// using UnityEngine.Rendering;

public class MyGameManager : MonoBehaviour {
	
	Controller2 player;
	[SerializeField] AudioSource windSoundPrefab;
	[SerializeField] NarrativeUI narrationUIPrefab;
	[SerializeField] EventSystem eventSysPrefab;
	
	[SerializeField]Controller2 playerPrefab;
	public List<MyGameRoom> rooms;
	[SerializeField] int roomNumMin = 3;
	[SerializeField] int roomNumMax = 5;
	int roomNumOffset = 0;
	public int curRoomCount { get; private set; }
	
	//Sun Sizes: 0.02 == tiny; 0.05 == medium; 0.1 == medium-large; 0.1 == huge
	[SerializeField] float sunSizeMin = 0.02f;
	[SerializeField] float sunSizeMax = 0.15f;
	
	[SerializeField] float sunSpeedMin = 0;
	[SerializeField] float sunSpeedMax = 10;
	[SerializeField] WorldColors[] worldColors;
	
	[SerializeField] Light sun;
	[SerializeField] Renderer oceanMat;
	Material skybox;
	public static WorldState state;
	static int narrativeState = -1;
	
	static string[] narrativeTexts = {
		"Day 0 \nOne giant step for mankind... \nOne giant step out the door.",
		"Day 1 \nIt was easier to leave than I thought. \nAll I had to do was forget.",
		"Day 3 \nThe device was easy enough to calibrate properly. \nJust a few variables to tweak and press the power button. Tada.",
		"Day 5 \nEach jump brings new skies. All so different, but... \nArbitrary.",
		"Day 7 \nI left it behind. A new world replacing the old. \nChasing a vista that would never satisfy.",
		"Day 9 \nThe endless expanse, the empty options left to me. \nIs this really better than before?",
		"Day 11 \nIt wasn’t all bad. \nWaking up early, the cafe bustling below \nThe smell of fresh bread drifting up",
		"Day 13 \nThat one peaceful corner in the back. \nA warm croissant flaking in the wind. \nMemories long ago, but held close for warmth.",
		// "Day 0
		// One giant step for mankind…
		// One giant step out the door.
		
		// Day 1
		// It was easier to leave than I thought.
		// All I had to do was forget.
		
		// Day 3
		// The device was easy enough to calibrate properly. 
		// Just a few variables to tweak and press the power button. Tada.
		
		// Day 5
		// Each jump brings new skies. All so different, but…
		// Arbitrary.
		
		// Day 7
		// I left it behind. A new world replacing the old. 
		// Chasing a vista that would never satisfy.
		
		// Day 9
		// The endless expanse, the empty options left to me. 
		// Is this really better than before? 
		
		// Day 11
		// It wasn’t all bad. 
		// Waking up early, the cafe bustling below
		// The smell of fresh bread drifting up
		
		// Day 13
		// That one peaceful corner in the back
		// A warm croissant flaking in the wind
		// Memories long ago, but held close for warmth",
	};
	static string CurrentNarrativeText {
		get {
			// return "";
			return narrativeTexts[Mathf.Clamp (narrativeState, 0, narrativeTexts.Length - 1)];
		}
	}
	// Use this for initialization
	void Awake () {
		baseRoomPool = new ObjectPool<MyGameRoom> (baseRoomPrefab);
		floorDomePool = new ObjectPool<Transform> (floorDomePrefab);
		floorSpikePool = new ObjectPool<Transform> (floorSpikePrefab);
		ceilingOpenPool = new ObjectPool<Transform> (ceilingOpenPrefab);
		ceilingClosedPool = new ObjectPool<Transform> (ceilingClosedPrefab);
		ceilingDomePool = new ObjectPool<Transform> (ceilingOpenPrefab);
		ceilingSpikePool = new ObjectPool<Transform> (ceilingSpikePrefab);		
		wallPool = new ObjectPool<Transform> (wallPrefab);
		doorPool = new ObjectPool<Transform> (doorPrefab);
		bridgePool = new ObjectPool<Transform> (bridgePrefab);
		portalPool = new ObjectPool<Transform> (portalPrefab);
		lightPool = new ObjectPool<Transform> (lightPrefab);
		torchPool = new ObjectPool<Transform> (torchPrefab);
		narrativePool = new ObjectPool<Transform> (narrativePrefab);
		
		decalPool = new List<ObjectPool<Transform>> ();
		rooms = new List<MyGameRoom> ();
		for (int i = 0; i < centerDecalPrefabs.Length; i++) {
			decalPool.Add (new ObjectPool<Transform> (centerDecalPrefabs[i])); 	
		}
		skybox = RenderSettings.skybox;
		
		if (windSound == null) {
			windSound = Instantiate (windSoundPrefab) as AudioSource;
			DontDestroyOnLoad (windSound.gameObject);
		}
		if (narrationUI == null) {
			narrationUI = Instantiate (narrationUIPrefab) as NarrativeUI;
			DontDestroyOnLoad (narrationUI.gameObject);
		}
		if (eventSys == null) {
			eventSys = Instantiate (eventSysPrefab) as EventSystem;
			DontDestroyOnLoad (eventSys.gameObject);
		}
		// DontDestroyOnLoad (this.gameObject);
		// DontDestroyOnLoad (windSound.gameObject);
		
		
		GenerateScene ();
	}
	
	// void OnLevelWasLoaded (int level) {
		
	// 	GenerateScene ();
	// }
	
	void Update () {
		sun.transform.Rotate (state.sunMoveSpeed * Time.deltaTime, 0, 0);		
		if (Input.GetKeyDown (KeyCode.R)) {
			Resources.UnloadUnusedAssets ();
			Application.LoadLevel (Application.loadedLevel);
			
		}
		if (deactivate) {
			deactivate = false;
			// rooms[0].gameObject.SetActive (false);
		}
	}
	
	bool deactivate = false;
	void GenerateScene () {
		narrativeState++;
		curRoomCount = UnityEngine.Random.Range (roomNumMin, roomNumMax + 1);
		SetWorldState ();
		
		MyGameRoom startRoom = baseRoomPool.SpawnFromPool (Vector3.zero);
		startRoom.Initialize (this);
		
		if (player == null) {
			player = Instantiate (playerPrefab, startRoom.transform.position + new Vector3 (-10, 16, -30), Quaternion.identity) as Controller2;
		} else {
			player.transform.position = startRoom.transform.position + new Vector3 (-10, 16, -30);
			player.transform.rotation = Quaternion.identity;
		}	
	}
	void ClearScene () {
		for (int i = 0; i < rooms.Count; i++) {
			rooms[i].ClearRoom ();
		}
		rooms.Clear ();
		bridgePool.DeactivatePool ();
	}
	
	void SetWorldState () {
		Material newBridgeMat = bridgeMaterials[UnityEngine.Random.Range (0, bridgeMaterials.Length)];
		Material newColumnMat = columnMaterials[UnityEngine.Random.Range (0, columnMaterials.Length)];	
		float atmoIntensity = 0;
		int atmoType = UnityEngine.Random.Range (0, 9);	//no atmo, low atmo, super atmo
		if (atmoType <= 4) {
			atmoIntensity = UnityEngine.Random.Range (0.1f, 0.4f); 
		} else if (atmoType <= 7) {
			atmoIntensity = UnityEngine.Random.Range (2.5f, 4f);
		} 
		skybox.SetFloat ("_AtmosphereThickness", atmoIntensity);
		
		float sunSpeed = UnityEngine.Random.Range (sunSpeedMin, sunSpeedMax);
		float sunSize = UnityEngine.Random.Range (sunSizeMin, sunSizeMax);
		skybox.SetFloat ("_SunSize", sunSize);
		sun.intensity = sunSize * 60;
		
		WorldColors color = worldColors[UnityEngine.Random.Range (0, worldColors.Length)];
		skybox.SetColor ("_SkyTint", color.skyColor);
		skybox.SetColor ("_GroundColor", color.groundColor);
		
		RenderSettings.fogColor = color.skyColor;
		
		if (UnityEngine.Random.value < 0.25) {
			oceanMat.enabled = true;
			oceanMat.material.color = color.groundColor;	
		} else {
			oceanMat.enabled = false;
		}
		
		System.Array values = Enum.GetValues (typeof(MyGameRoom.RoomFloorType));
		MyGameRoom.RoomFloorType _floorType = (MyGameRoom.RoomFloorType)values.GetValue (UnityEngine.Random.Range(0, values.Length));
		
		values = Enum.GetValues (typeof(MyGameRoom.RoomCeilingType));
		MyGameRoom.RoomCeilingType _ceilingType = (MyGameRoom.RoomCeilingType)values.GetValue (UnityEngine.Random.Range(0, values.Length));

		state = new WorldState ( newBridgeMat, newColumnMat, floorTexs[UnityEngine.Random.Range (0, floorTexs.Length)], wallTexs[UnityEngine.Random.Range (0, wallTexs.Length)], sunSize, sunSpeed, color, new MyGameRoom.RoomData (_floorType, _ceilingType) );
	}
	
//==========================================
//OBJECT PREFABS
//==========================================
	[Header("Generation Prefabs")]
	[SerializeField] MyGameRoom baseRoomPrefab;
	
	[SerializeField] Transform floorSpikePrefab;
	[SerializeField] Transform floorDomePrefab;
	
	[SerializeField] Transform ceilingOpenPrefab;
	[SerializeField] Transform ceilingClosedPrefab;
	[SerializeField] Transform ceilingSpikePrefab;
	[SerializeField] Transform ceilingDomePrefab;
	
	[SerializeField] Transform wallPrefab;
	[SerializeField] Transform doorPrefab;
	[SerializeField] Transform bridgePrefab;
	[SerializeField] Transform[] centerDecalPrefabs;	
	[SerializeField] Transform portalPrefab;
	[SerializeField] Transform lightPrefab;
	[SerializeField] Transform torchPrefab;
	[SerializeField] Transform narrativePrefab;
	
//==========================================
//MATERIALS
//==========================================
	[Header("Generation Materials")]	
	public Material[] bridgeMaterials;
	public Material[] columnMaterials;	
	public Texture[] wallTexs;
	public Texture[] floorTexs;
	
		
//==========================================
//OBJECT POOLS
//==========================================	
	public ObjectPool<MyGameRoom> baseRoomPool;
	
	public ObjectPool<Transform> floorSpikePool;
	public ObjectPool<Transform> floorDomePool;
	
	public ObjectPool<Transform> ceilingOpenPool;
	public ObjectPool<Transform> ceilingClosedPool;
	public ObjectPool<Transform> ceilingDomePool; 
	public ObjectPool<Transform> ceilingSpikePool;
	
	public ObjectPool<Transform> wallPool;
	public ObjectPool<Transform> doorPool;	
	public ObjectPool<Transform> bridgePool;
	public List<ObjectPool<Transform>> decalPool;
	public ObjectPool<Transform> portalPool;
	public ObjectPool<Transform> lightPool;
	public ObjectPool<Transform> torchPool;
	public ObjectPool<Transform> narrativePool;
	
//==========================================
//STATIC FUNCTIONALITY
//==========================================	
		
	//permanent between scenes
	static AudioSource windSound;
	// static Canvas uiCanvas;
	static NarrativeUI narrationUI;
	static EventSystem eventSys;
	public static void TogglePromptText (bool show) {
		if (narrationUI != null) {
			narrationUI.showPrompt = show;
		}
	}
	public static void ToggleNarrationText (bool show) {
		if (narrationUI != null) {
			narrationUI.textUI.text = CurrentNarrativeText;
			narrationUI.showNarration = show;
		}
	}
	// static bool showPrompt;
	// static bool showNarration;
	// static void UpdateTexts () {
	// 	float speed = 2f;
	// 	float promptTarget = (showPrompt) ? 1 : 0;
	// 	narrationUI.promptGroup.alpha = Mathf.MoveTowards (narrationUI.promptGroup.alpha, promptTarget, speed * Time.deltaTime);
	// 	float narrationTarget = (showNarration) ? 1 : 0;
	// 	narrationUI.narrationGroup.alpha = Mathf.MoveTowards (narrationUI.narrationGroup.alpha, narrationTarget, speed * Time.deltaTime);
	// 	// if (showPrompt) {
			
	// 	// } else {
			
	// 	// }
	// 	// if (showNarration) {
			
	// 	// }
	// }
	
	public int previousBridgeIndex { get; set; }
	
	[System.Serializable]
	public struct WorldState {
		// bool 
		public Material bridgeMat;
		public Material columnMat;
		public Texture floorTex;
		public Texture wallTex;
		
		// public Transform roomPrefab;
		public float sunSize;
		public float sunMoveSpeed;
		public WorldColors colors;
		public MyGameRoom.RoomData roomTypeData;
		public WorldState (Material _bridgeMat, Material _columnMat, Texture _floorTex, Texture _wallTex, float _sunSize, float _sunMoveSpeed, WorldColors _colors, MyGameRoom.RoomData _roomTypeData) {
			bridgeMat = _bridgeMat;
			columnMat = _columnMat;
			floorTex = _floorTex;
			wallTex = _wallTex;
			// roomPrefab = _roomPrefab;
			sunSize = _sunSize;
			sunMoveSpeed = _sunMoveSpeed;
			colors = _colors;
			roomTypeData = _roomTypeData;
		}
	}	
	[System.Serializable]
	public struct WorldColors {
		public Color groundColor;
		public Color skyColor;
		public Color roomLightsColor;

	}	
}
