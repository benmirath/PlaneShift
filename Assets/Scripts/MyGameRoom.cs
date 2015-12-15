using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class MyGameRoom : MonoBehaviour {
		
		public Vector3 roomPos;
		public Transform attachmentAnchor;
		
		public Transform wallAnchor1;
		public Transform wallAnchor2;
		public Transform wallAnchor3;
		public Transform wallAnchor4;
		public Transform wallAnchor5;
		
		[SerializeField] Renderer[] columnRenderers;
		
		MyGameManager gameManager;
		MyGameRoom prevRoom;
		RoomEntranceTrigger trigger;
		
		
		List<int> nextRoomIndex;
		List<MyGameRoom> nextRoom;
		
		Transform baseRoom;
		List<Transform> walls;
		List<Transform> doors;
		
		const int wallAngle = 72; 
		Vector3 roomDiff = new Vector3 (0, 0, 360);
		
		void OnDisable () {
			roomInitialized = false;
		}
		
		void Awake () {
			doors = new List<Transform> ();
			walls = new List<Transform> ();
			nextRoomIndex = new List<int> ();
			nextRoom = new List<MyGameRoom> ();
		}
		
		public void Initialize (MyGameManager _game, MyGameRoom _prevRoom = null, bool _finalRoom = false) {
			gameManager = _game;
			prevRoom = _prevRoom;
			roomPos = transform.position;
			baseRoom = transform;			
			trigger = baseRoom.gameObject.AddComponent<RoomEntranceTrigger> ();
			
			//previous room cleanup
			roomInitialized = false;
			
			// while (attachmentAnchor.childCount > 0) {
			// 	attachmentAnchor.GetChild (0).gameObject.SetActive (false);
			// 	attachmentAnchor.GetChild (0).parent = null;
			// }
			
			//calculate doors - generate walkway and attached game rooms for each door
			int doorCountAdj = (prevRoom != null) ? 1 : 0;
			int doorCount = (_finalRoom) ?  doorCountAdj : 1 + doorCountAdj;

			for (int i = 0; i < doorCount; i++) {
				doors.Add (_game.doorPool.SpawnFromPool (roomPos));	
			}
			
			//generate walls
			int wallCount = 5 - doorCount;
			for (int i = 0; i < wallCount; i++) {
				walls.Add (_game.wallPool.SpawnFromPool (roomPos));
			}

			//set wall and door orientations			
			int wallIndex = 0;
			int doorIndex = 0;
			int rotation = 0;
			int targ = UnityEngine.Random.Range (2,4);
			
			for (int i = 0; i < 5; i++) {
				// if (doorIndex < doorCount && (i == 0 || i == 2 || i == 3)) {	//theres a door available and its an appropriate slot
				if (doorIndex < doorCount && (i == 0 || i == targ)) {	//theres a door available and its an appropriate slot
					if (!_finalRoom && (i != 0 || prevRoom == null)) {
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
			
			// if (prevRoom != null && !_finalRoom) {
				Transform decal = gameManager.decalPool[UnityEngine.Random.Range (0, gameManager.decalPool.Count)].SpawnFromPool();
				decal.parent = attachmentAnchor;
				decal.localPosition = new Vector3 (0, 2, 0);
								
				int roomType = UnityEngine.Random.Range (0, 5);
				if (roomType >= 4) {
					
				} else if (roomType >= 3) {
					
				}	
			// }
			
			//Column Customization
			for (int j = 0; j < columnRenderers.Length; j++) {
				columnRenderers[j].material = MyGameManager.state.columnMat;
			}
			
			
			transform.name += gameManager.rooms.Count;
			
			if (prevRoom != null) {
				transform.transform.LookAt (prevRoom.transform, Vector3.up);
				
				Vector3 offset = new Vector3 (0, -18, 0);
				transform.eulerAngles = transform.transform.eulerAngles + offset;
			}
			InitializeConnections ();
		}
		
		bool roomInitialized = false;
		const float roomRot = 180;
		const float roomAngOffset = 18;
		int roomState = 0;
		void InitializeConnections () {
			if (roomInitialized) return;
			
			roomInitialized = true;
			gameManager.rooms.Add (this);
			Debug.LogWarning ("Starting Build");
			for (int i = 0; i < nextRoomIndex.Count; i++) {
				Debug.LogWarning ("Loop Count: " + i);
				Transform bridge = gameManager.bridgePool.SpawnFromPool (roomPos);
		
				bridge.eulerAngles = transform.eulerAngles + new Vector3 (0, (wallAngle * nextRoomIndex[i]), 0);
				Renderer bridgeRend = bridge.GetComponentInChildren<Renderer> ();
				if (bridgeRend != null) {
					bridgeRend.material = MyGameManager.state.bridgeMat;
				}
				
				MyGameRoom newRoom = gameManager.baseRoomPool.SpawnFromPool (roomPos + roomDiff);
				nextRoom.Add (newRoom);
				
				newRoom.transform.RotateAround (roomPos, Vector3.up, 18 + transform.eulerAngles.y + (wallAngle * nextRoomIndex[i]));
				newRoom.Initialize (gameManager, this, gameManager.rooms.Count >= gameManager.curRoomCount);				
			}
		}
		
		public void ClearRoom () {
			// while (attachmentAnchor.childCount > 0) {
			nextRoom.Clear ();
			nextRoomIndex.Clear ();
			doors.Clear ();
			walls.Clear ();
				
			for (int i = 0; i < attachmentAnchor.childCount; i++) {
				attachmentAnchor.GetChild (i).gameObject.SetActive (false);
				// attachmentAnchor.GetChild (0).parent = null;
				// attachmentAnchor.chi
			}
			attachmentAnchor.DetachChildren ();
			// StartCoroutine (selfDeactivate ());
			gameObject.SetActive (false);
		}
		
		IEnumerator selfDeactivate () {
			Debug.LogError ("Off1");
			yield return new WaitForEndOfFrame ();
			Debug.LogError ("Off2");
			gameObject.SetActive (false);	
		}
	}