using UnityEngine;
using System.Collections.Generic;
// using UnityEngine.Rendering;

public class MyGameManager : MonoBehaviour {
	Controller2 player;
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
	Material skybox;
	public static WorldState state;
	// Use this for initialization
	void Awake () {
		baseRoomPool = new ObjectPool<MyGameRoom> (baseRoomPrefab);
		wallPool = new ObjectPool<Transform> (wallPrefab);
		doorPool = new ObjectPool<Transform> (doorPrefab);
		bridgePool = new ObjectPool<Transform> (bridgePrefab);
		decalPool = new List<ObjectPool<Transform>> ();
		rooms = new List<MyGameRoom> ();
		for (int i = 0; i < centerDecalPrefabs.Length; i++) {
			decalPool.Add (new ObjectPool<Transform> (centerDecalPrefabs[i])); 	
		}
		
		
		skybox = RenderSettings.skybox;
		GenerateScene ();
	}
	
	
	void Update () {
		sun.transform.Rotate (state.sunMoveSpeed * Time.deltaTime, 0, 0);
		
		if (Input.GetKeyDown (KeyCode.R)) {
			Debug.LogError (rooms.Count);
			ClearScene ();
			Debug.LogError (rooms.Count);
			
			GenerateScene ();
		}
		if (deactivate) {
			deactivate = false;
			// rooms[0].gameObject.SetActive (false);
		}
	}
	
	bool deactivate = false;
	
	void GenerateScene () {
		curRoomCount = UnityEngine.Random.Range (roomNumMin, roomNumMax + 1);
		// Debug.LogWarning (curRoomCount);		
		SetWorldState ();
		
		MyGameRoom startRoom = baseRoomPool.SpawnFromPool (Vector3.zero);
		startRoom.Initialize (this);
		
		if (player == null) {
			player = Instantiate (playerPrefab, startRoom.roomPos + new Vector3 (-10, 16, -30), Quaternion.identity) as Controller2;
		} else {
			player.transform.position = startRoom.roomPos + new Vector3 (-10, 16, -30);
			player.transform.rotation = Quaternion.identity;
		}
		
	}
	void GenerateScene2 () {
		curRoomCount = UnityEngine.Random.Range (roomNumMin, roomNumMax + 1);
		// Debug.LogWarning (curRoomCount);		
		SetWorldState ();
		
		MyGameRoom startRoom = baseRoomPool.SpawnFromPool2 (Vector3.zero);
		startRoom.Initialize (this);
		
		// if (player == null) {
		// 	player = Instantiate (playerPrefab, startRoom.roomPos + new Vector3 (-10, 16, -30), Quaternion.identity) as Controller2;
		// } else {
		// 	player.transform.position = startRoom.roomPos + new Vector3 (-10, 16, -30);
		// 	player.transform.rotation = Quaternion.identity;
		// }
		
	}
	void ClearScene () {
		for (int i = 0; i < rooms.Count; i++) {
			rooms[i].ClearRoom ();
			// rooms[i].gameObject.SetActive (false);
		}
		Debug.LogError ("Clearing");
		// rooms[0].gameObject.SetActive (false);
		rooms.Clear ();
		// 
		// baseRoomPool.DeactivatePool ();
		// baseRoomPool.DeactivatePool ();
		bridgePool.DeactivatePool ();
	}
	
	void SetWorldState () {
		Material newBridgeMat = bridgeMaterials[UnityEngine.Random.Range (0, bridgeMaterials.Length)];
		Material newColumnMat = columnMaterials[UnityEngine.Random.Range (0, columnMaterials.Length)];
		Transform newRoomPrefab = roomPrefabs[UnityEngine.Random.Range (0, roomPrefabs.Length)];
	
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
		
		state = new WorldState ( newBridgeMat, newColumnMat, newRoomPrefab, sunSize, sunSpeed, color);
	}
	
//==========================================
//OBJECT PREFABS
//==========================================
	// [SerializeField] Transform floorPrefab;
	[SerializeField] MyGameRoom baseRoomPrefab;
	[SerializeField] Transform wallPrefab;
	[SerializeField] Transform doorPrefab;
	[SerializeField] Transform bridgePrefab;
	
//==========================================
//OBJECT POOLS
//==========================================	
	// ObjectPool<Transform> floorPool;
	public ObjectPool<MyGameRoom> baseRoomPool;
	public ObjectPool<Transform> wallPool;
	public ObjectPool<Transform> doorPool;	
	public ObjectPool<Transform> bridgePool;
	public List<ObjectPool<Transform>> decalPool;
	
//==========================================
//MATERIALS
//==========================================
	[Header("Generation Materials")]
	public Transform[] roomPrefabs;
	public Transform[] centerDecalPrefabs;
	public Material[] bridgeMaterials;
	public Material[] columnMaterials;
	
	// public Material[] 
	
	
	public int previousBridgeIndex { get; set; }
	
	[System.Serializable]
	public struct WorldState {
		// bool 
		public Material bridgeMat;
		public Material columnMat;
		public Transform roomPrefab;
		public float sunSize;
		public float sunMoveSpeed;
		public WorldColors colors;
		public WorldState (Material _bridgeMat, Material _columnMat, Transform _roomPrefab, float _sunSize, float _sunMoveSpeed, WorldColors _colors) {
			bridgeMat = _bridgeMat;
			columnMat = _columnMat;
			roomPrefab = _roomPrefab;
			sunSize = _sunSize;
			sunMoveSpeed = _sunMoveSpeed;
			colors = _colors;
		}
	}	
	[System.Serializable]
	public struct WorldColors {
		public Color groundColor;
		public Color skyColor;
		public Color roomLightsColor;
		// public WorldColors (Color _groundColor, Color _skyColor) {
		// 	groundColor = _groundColor;
		// 	skyColor = _skyColor;
			
		// 	roomLightsColor = Color.white;
		// }
	}	
}
