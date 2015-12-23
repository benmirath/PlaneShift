using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class MyGameRoom : MonoBehaviour {
		//floor - no spike, spike
		//ceiling - no ceiling, open ceiling (enclosing cicle), full ceiling, domed ceiling 
		//columns(if ceiling) - normal, spiked (static and animated), twist (static and animated), pulsing (static and animated)
		
		public enum RoomFloorType {
			Ungarnished,
			Spike,
			Dome
		}
		public enum RoomCeilingType {
			None,
			Open,
			Closed,
			Spike,
			Dome
		}
		
		
		public struct RoomData {
			public RoomFloorType floorType;
			public RoomCeilingType ceilingType;
			
			public RoomData (RoomFloorType _floorType, RoomCeilingType _ceilingType) {
				floorType = _floorType;
				ceilingType = _ceilingType;
			}
		}
		
		public Transform attachmentAnchor;
		
		[SerializeField] Renderer[] columnRenderers;
		[SerializeField] Renderer[] groundRenderers;
		
		MyGameManager gameManager;
		MyGameRoom prevRoom;
		RoomEntranceTrigger trigger;
		
		
		List<int> nextRoomIndex;
		List<MyGameRoom> nextRoom;
		
		Transform baseRoom;
		List<Transform> walls;
		List<Transform> doors;
		
		Vector3 roomPos;
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
		
		void AttachObject (Transform _attach, bool _rotationReset = false) {
			_attach.parent = attachmentAnchor;
			_attach.localPosition = Vector3.zero;
			if (_rotationReset) _attach.localRotation = Quaternion.identity;
		}
		
		public void Initialize (MyGameManager _game, MyGameRoom _prevRoom = null, bool _finalRoom = false) {
			gameManager = _game;
			prevRoom = _prevRoom;
			roomPos = transform.position;
			baseRoom = transform;			
			trigger = baseRoom.gameObject.AddComponent<RoomEntranceTrigger> ();
			//previous room cleanup
			roomInitialized = false;
			
			// Texture tex = gameManager.floorTexs[UnityEngine.Random.Range (0, gameManager.floorTexs.Length)];
			for (int i = 0; i < groundRenderers.Length; i++) {
				groundRenderers[i].material.SetTexture ("_MainTex", MyGameManager.state.wallTex);
			}
			
			bool roofless = (MyGameManager.state.roomTypeData.ceilingType == RoomCeilingType.None || MyGameManager.state.roomTypeData.ceilingType == RoomCeilingType.Open);
			//generate floor 
			if (MyGameManager.state.roomTypeData.floorType == RoomFloorType.Dome) {
				AttachObject (gameManager.floorDomePool.SpawnFromPool ());
			} else if (MyGameManager.state.roomTypeData.floorType == RoomFloorType.Spike) {
				AttachObject (gameManager.floorSpikePool.SpawnFromPool ());
			}			
			
			//calculate doors - generate walkway and attached game rooms for each door
			int doorCountAdj = (prevRoom != null) ? 1 : 0;
			int doorCount = (_finalRoom) ?  doorCountAdj : 1 + doorCountAdj;

			if (!roofless) {
				if (MyGameManager.state.roomTypeData.ceilingType == RoomCeilingType.Spike) {
					AttachObject (gameManager.ceilingSpikePool.SpawnFromPool (), true);
				} else if (MyGameManager.state.roomTypeData.ceilingType == RoomCeilingType.Dome) {
					AttachObject (gameManager.ceilingDomePool.SpawnFromPool (), true);
				} else {
					AttachObject (gameManager.ceilingClosedPool.SpawnFromPool (), true);
				}
				
				for (int i = 0; i < doorCount; i++) {
					doors.Add (_game.doorPool.SpawnFromPool (roomPos));	
				}
				
				//generate walls
				int wallCount = 5 - doorCount;
				for (int i = 0; i < wallCount; i++) {
					walls.Add (_game.wallPool.SpawnFromPool (roomPos));
				}	
			}
			//set wall and door orientations			
			int wallIndex = 0;
			int doorIndex = 0;
			int rotation = 0;
			int targ = UnityEngine.Random.Range (2,4);
			
			for (int i = 0; i < 5; i++) {
				if (doorIndex < doorCount && (i == 0 || i == targ)) {	//theres a door available and its an appropriate slot
					if (!_finalRoom && (i != 0 || prevRoom == null)) {
						nextRoomIndex.Add (i);
					}
					if (!roofless) {
						doors[doorIndex].parent = attachmentAnchor;
						doors[doorIndex].eulerAngles = new Vector3 (0, doors[doorIndex].parent.eulerAngles.y + rotation, 0);
						Renderer[] rend = doors[doorIndex].GetComponentsInChildren<Renderer> ();
						// if (rend != null) {
						for (int j = 0; j < rend.Length; j++) {
							rend[j].material.SetTexture ("_MainTex", MyGameManager.state.wallTex);
						}
					}
					doorIndex++;	
				} else {
					if (!roofless) {
						walls[wallIndex].parent = attachmentAnchor;
						walls[wallIndex].eulerAngles = new Vector3 (0, walls[wallIndex].parent.eulerAngles.y + rotation, 0);
						Renderer[] rend = walls[wallIndex].GetComponentsInChildren<Renderer> ();
						// if (rend != null) {
						for (int j = 0; j < rend.Length; j++) {
							rend[j].material.SetTexture ("_MainTex", MyGameManager.state.wallTex);
						}
					}
					wallIndex++;	
				}
				rotation += wallAngle;
			}
			if (prevRoom == null) {
				// Transform decal = gameManager.decalPool[UnityEngine.Random.Range (0, gameManager.decalPool.Count)].SpawnFromPool();
				// decal.parent = attachmentAnchor;
				// decal.localPosition = new Vector3 (0, 2, 0);
				// AttachObject (gameManager.lightPool.SpawnFromPool());
				AttachObject (gameManager.narrativePool.SpawnFromPool());
				
			} else if (_finalRoom) {
				// Transform decal = gameManager.decalPool[UnityEngine.Random.Range (0, gameManager.decalPool.Count)].SpawnFromPool();
				AttachObject (gameManager.portalPool.SpawnFromPool());
				// decal.parent = attachmentAnchor;
				// decal.localPosition = new Vector3 (0, 2, 0);
								
			} else {
				if (roofless) {
					AttachObject (gameManager.torchPool.SpawnFromPool());
					// Transform decal = gameManager.decalPool[UnityEngine.Random.Range (0, gameManager.decalPool.Count)].SpawnFromPool();
					// decal.parent = attachmentAnchor;
					// decal.localPosition = new Vector3 (0, 2, 0);	
				} else {
					AttachObject (gameManager.lightPool.SpawnFromPool());
				}
				
								
				int roomType = UnityEngine.Random.Range (0, 5);
				if (roomType >= 4) {
					
				} else if (roomType >= 3) {
					
				}	
			}
			if (roofless) {
				for (int j = 0; j < columnRenderers.Length; j++) {
					columnRenderers[j].gameObject.SetActive (false);
				}	
			} else {
			//Column Customization
				for (int j = 0; j < columnRenderers.Length; j++) {
					columnRenderers[j].gameObject.SetActive (true);
					columnRenderers[j].material = MyGameManager.state.columnMat;
				}
			}
			
			
			// transform.name += gameManager.rooms.Count;
			
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