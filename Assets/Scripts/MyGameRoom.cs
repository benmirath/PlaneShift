using UnityEngine;
using System.Collections.Generic;

public class MyGameRoom : MonoBehaviour {
		MyGameManager gameManager;
		public Vector3 roomPos;
		public Transform attachmentAnchor;
		
		RoomEntranceTrigger trigger;
		
		// MyGameManager
		MyGameRoom prevRoom;
		
		List<int> nextRoomIndex;
		List<MyGameRoom> nextRoom;
		List<Transform> nextRoomBridge;
		
		// Transform floor;
		// Transform ceiling;
		Transform baseRoom;
		List<Transform> walls;
		List<Transform> doors;
		
		const int wallAngle = 72; 
		Vector3 roomDiff = new Vector3 (0, 0, 360);
		
		void OnEnable () {
			RoomEntranceTrigger.OnPlayerEnteredRoom += GenerateAdjacentRoomss;
		}
		void OnDisable () {
			RoomEntranceTrigger.OnPlayerEnteredRoom -= GenerateAdjacentRoomss;
		}
		
		void Awake () {
			doors = new List<Transform> ();
			walls = new List<Transform> ();
			nextRoomIndex = new List<int> ();
			nextRoom = new List<MyGameRoom> ();
			nextRoomBridge = new List<Transform> ();
		}
		
		public void Initialize (MyGameManager _game, MyGameRoom _prevRoom = null) {
			gameManager = _game;
			prevRoom = _prevRoom;
			roomPos = transform.position;
			baseRoom = transform;			
			trigger = baseRoom.gameObject.AddComponent<RoomEntranceTrigger> ();
			
			roomInitialized = false;
			while (attachmentAnchor.childCount > 0) {
				attachmentAnchor.GetChild (0).gameObject.SetActive (false);
				attachmentAnchor.GetChild (0).parent = null;
			}
			
			//calculate doors - generate walkway and attached game rooms for each door
			int doorCountAdj = (prevRoom != null) ? 1 : 0;
			int doorCount = 1 + doorCountAdj;
			// int doorCount = UnityEngine.Random.Range (0, 1) + doorCountAdj;	//increase to 2 once rest of generation is working
			for (int i = 0; i < doorCount; i++) {
				doors.Add (_game.doorPool.SpawnFromPool (roomPos));	
			}
			
			//generate walls
			int wallCount = 5 - doorCount;
			for (int i = 0; i < wallCount; i++) {
				walls.Add (_game.wallPool.SpawnFromPool (roomPos));
			}
			
			Debug.LogError (doorCount);
			
			int wallIndex = 0;
			int doorIndex = 0;
			int rotation = 0;
			for (int i = 0; i < 5; i++) {
				if (doorIndex < doorCount && (i == 0 || i == 2 || i == 3)) {	//theres a door available and its an appropriate slot
					if (i != 0 || prevRoom == null) {
						nextRoomIndex.Add (i);
					}
					doors[doorIndex].parent = attachmentAnchor;
					doors[doorIndex].eulerAngles = new Vector3 (0, doors[doorIndex].parent.eulerAngles.y + rotation, 0);
					doorIndex++;	
				} else {
					walls[wallIndex].parent = attachmentAnchor;
					walls[wallIndex].eulerAngles = new Vector3 (0, walls[wallIndex].parent.eulerAngles.y + rotation, 0);
					wallIndex++;	
				}
				rotation += wallAngle;
			}
			
			if (prevRoom == null) {
				InitializeConnections ();
				Debug.LogWarning("Intizlization wrapup");
			}
			
			
			
			 
			
			
			// Vector3 floorPos = pos;
			// floor = game.floorPool.SpawnFromPool();
			
			// Vector3 ceilingPos = pos + new Vector3 (0, 5, 0);
			// ceiling = game.ceilingPool.SpawnFromPool();
			
			
			
			//doors
			// doors = new List<Transform> ();			
			// int doorCountAdj = (prevRoom != null) ? 1 : 0;
			// int doorCount = UnityEngine.Random.Range (0, 2) + doorCountAdj;
			
			// for (int i = 0; i < doorCount; i++) {
			// 	doors.Add (game.doorPool.SpawnFromPool ());			
			// }			 	
			
			RoomEntranceTrigger.OnPlayerEnteredRoom += GenerateAdjacentRoomss;
		}
		
		bool roomInitialized = false;
		static float roomRot = 180;
		void InitializeConnections () {
			if (roomInitialized) return;
			roomInitialized = true;
			Debug.LogWarning ("Starting Build");
			for (int i = 0; i < nextRoomIndex.Count; i++) {
				Debug.LogWarning ("Loop Count: " + i);
				Transform bridge = gameManager.bridgePool.SpawnFromPool (roomPos);
				
				// Vector3 adj = (prevRoom == null) ? Vector3.zero : transform.eulerAngles;
				// Vector3 adj = (prevRoom == null) ? Vector3.zero : new Vector3 (0, transform.eulerAngles.y, 0);
				
				// Vector3 adj = (prevRoom == null) ? transform.eulerAngles : transform.eulerAngles + prevRoom.transform.eulerAngles;
				// float adj = (prevRoom == null) ? 0 : prevRoom.transform.eulerAngles.y;
				
				// float adj = 18 * gameManager.rooms.Count;
				// float adj = 0;
				// float adj = (36 + 180) * Mathf.Max (0, gameManager.rooms.Count - 2);
				// if (prevRoom != null) {
					// if (prevRoom.prevRoom != null) {
						// adj = prevRoom.transform.eulerAngles.y + 18;
					// } else {
						// adj = prevRoom.transform.eulerAngles.y;
					// }
				// }
				
				float adj = (gameManager.rooms.Count > 2) ? 180 : 0;
				// float adj = 0;
				if (gameManager.rooms.Count > 2) {
					// adj = 180;
					adj = 180 + 36;
				}
				// bridge.eulerAngles = new Vector3 (0, transform.eulerAngles.y + (wallAngle * nextRoomIndex[i]), 0);
				// bridge.eulerAngles = adj + new Vector3 (0, wallAngle * nextRoomIndex[i], 0);
				Debug.Log (gameObject.GetInstanceID() + ": " + nextRoomIndex[i]);
				
				bridge.eulerAngles = transform.eulerAngles + new Vector3 (0, adj + (wallAngle * nextRoomIndex[i]), 0);
				
				MyGameRoom newRoom = gameManager.baseRoomPool.SpawnFromPool (roomPos + roomDiff);
				nextRoom.Add (newRoom);
				
				
				// newRoom.transform.RotateAround (roomPos, Vector3.up,  wallAngle * nextRoomIndex[i]);
				newRoom.transform.RotateAround (roomPos, Vector3.up, 18 + adj + transform.eulerAngles.y + (wallAngle * nextRoomIndex[i]));
				// newRoom.transform.eulerAngles = adj + (Vector3.up * transform.eulerAngles.y);
				newRoom.transform.eulerAngles = Vector3.up * (transform.eulerAngles.y + roomRot);
				newRoom.Initialize (gameManager, this);
				// roomRot += 180;				
			}
			
			gameManager.rooms.Add (this);
		}
		// ~GameRoom () {
		// 	RoomEntranceTrigger.OnPlayerEnteredRoom -= GenerateAdjacentRoomss;
		// }
		
		public void SetRoomMaterials () {
			
		}
		
		public void GenerateAdjacentRoomss (RoomEntranceTrigger activatedTrigger) {
			if (activatedTrigger != trigger) return;
			
			Debug.LogWarning ("Player detected in room, generating next rooms!");
			
			// for (int i = 0; i < nextRoomIndex.Count; i++) {
			// 	Transform bridge = gameManager.bridgePool.SpawnFromPool (roomPos);
			// 	bridge.eulerAngles = new Vector3 (0, wallAngle * nextRoomIndex[i], 0);
				
			// 	// Vector3 dir = Mathf.
				
			// 	MyGameRoom newRoom = gameManager.baseRoomPool.SpawnFromPool (roomPos + roomDiff);
				
			// 	// newRoom.transform.RotateAround (roomPos, Vector3.up,  wallAngle * nextRoomIndex[i]);
			// 	newRoom.transform.RotateAround (roomPos, Vector3.up,  18 + (wallAngle * nextRoomIndex[i]));
			// }
			
			
			if (nextRoom.Count > 0) {
				for (int i = 0; i < nextRoom.Count; i++) {
					Debug.LogWarning (i);
					// nextRoom[i].GenerateAdjacentRoomss2 ();
					nextRoom[i].InitializeConnections ();
				}
			}
			
			// MyGameRoom newRoom
			
		}
		public void GenerateAdjacentRoomss2 () {
			// for (int i = 0; i < nextRoomIndex.Count; i++) {
			// 	Transform bridge = gameManager.bridgePool.SpawnFromPool (roomPos);
			// 	bridge.eulerAngles = new Vector3 (0, wallAngle * nextRoomIndex[i], 0);
				
			// 	// Vector3 dir = Mathf.
				
			// 	MyGameRoom newRoom = gameManager.baseRoomPool.SpawnFromPool (roomPos + roomDiff);
				
			// 	// newRoom.transform.RotateAround (roomPos, Vector3.up,  wallAngle * nextRoomIndex[i]);
			// 	newRoom.transform.RotateAround (roomPos, Vector3.up,  18 + (wallAngle * nextRoomIndex[i]));
			// }
		}
		
	}