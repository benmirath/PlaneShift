using UnityEngine;
using System.Collections.Generic;

public class MyGameRoom : MonoBehaviour {
		public Vector3 roomPos;
		
		RoomEntranceTrigger trigger;
		
		MyGameRoom prevRoom;
		
		int nextRoomIndex;
		List<MyGameRoom> nextRoom;
		
		// Transform floor;
		// Transform ceiling;
		Transform baseRoom;
		List<Transform> walls;
		List<Transform> doors;
		
		const int wallAngle = 72; 
		
		void OnEnable () {
			RoomEntranceTrigger.OnPlayerEnteredRoom += GenerateAdjacentRoomss;
		}
		void OnDisable () {
			RoomEntranceTrigger.OnPlayerEnteredRoom -= GenerateAdjacentRoomss;
		}
		
		void Awake () {
			doors = new List<Transform> ();
			walls = new List<Transform> ();
			nextRoom = new List<MyGameRoom> ();
		}
		
		public void Initialize (MyGameManager _game, MyGameRoom _prevRoom = null) {
			roomPos = transform.position;
			// baseRoom = game.baseRoomPool.SpawnFromPool (roomPos);
			// baseRoom = _baseRoom;
			baseRoom = transform;
			
			trigger = baseRoom.gameObject.AddComponent<RoomEntranceTrigger> ();

			
			
			
			//calculate doors
			//generate walkway and game rooms for each door
						
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
			
			int wallIndex = 0;
			int doorIndex = 0;
			int rotation = 0;
			for (int i = 0; i < 5; i++) {
				if (doorIndex < doorCount && (i == 0 || i == 2 || i == 3)) {	//theres a door available and its an appropriate slot
					if (i != 0) {
						nextRoomIndex = i;
					}
					
					walls[doorIndex].eulerAngles = new Vector3 (0, rotation, 0);
					doorIndex++;	
				} else {
					walls[wallIndex].eulerAngles = new Vector3 (0, rotation, 0);
					wallIndex++;	
				}
				rotation += wallAngle;
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
		// ~GameRoom () {
		// 	RoomEntranceTrigger.OnPlayerEnteredRoom -= GenerateAdjacentRoomss;
		// }
		
		public void SetRoomMaterials () {
			
		}
		
		public void GenerateAdjacentRoomss (RoomEntranceTrigger activatedTrigger) {
			if (activatedTrigger != trigger) return;
			
			Debug.LogWarning ("Player detected in room, generating next rooms!");
			
		}
		
	}