using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Room : MonoBehaviour {
	public enum RoomType {
		//Indoors
		Gallery,		//rest spot
		TrapChamber,	//has dropping ceiling or crushing walls
		//Outdoors
		Beach,			//rest spot
		Expanse,		//platforms high up in open space, uses swing
		Escape			//platforms that are slowly dropping into expanse or ocean
	}

	Vector3 startPoint;
	Vector3 exitPoint;

	BoxCollider startTrigger;
	BoxCollider exitTrigger;

	public RoomType roomType;
	public float startDelay = 5;	//amount of time to wait before room trial begins

	[SerializeField] Room prefab;

	Room prevRoom;
	Room nextRoom;

	void OnEnable () {
		RoomEntranceTrigger.OnPlayerEnteredRoom += OnEntranceTriggered;
	}
	void OnDisable () {
		RoomEntranceTrigger.OnPlayerEnteredRoom -= OnEntranceTriggered;
	}

	void OnGizmoDrawSelected () {
		//draw start and exit connect points
	}


	void OnEntranceTriggered (RoomEntranceTrigger trigger) {
		Debug.LogError ("PLAYER HIT");
		//load next room
		// LoadNextRoom ();
		//if not gallery or beach, trigger room activation
		//if indoors, unlock previous room

	}
	void SetRoomObjects () {
		//set (or reset) any room objects (any falling ceiling or falling floors or etc
		if (roomType == RoomType.TrapChamber) {
			//reset any wall or ceiling traps
		} else if (roomType == RoomType.Expanse) {
			//randomize central platforming section
		} else if (roomType == RoomType.Escape) {
			//reset and randomize floor sections
		}

	}

	//call after room entrance has been triggered
	// void LoadNextRoom () {
	// 	//choose room type (if indoor, pick outdoor, and vice versa)

	// 	RoomType nextRoomType = (roomType == RoomType.Gallery || roomType == RoomType.TrapChamber) ? (RoomType)Random.Range (2, 5) : (RoomType)Random.Range (0, 2);		//if indoors room, select outdoors room range
	// 	nextRoomType = RoomType.Gallery;



	// 	if (roomType == RoomType.Gallery || roomType == RoomType.TrapChamber) {	//indoors

	// 	} else {
		
	// 	}

	// 	//choose room exit type (drop or portal)
	// }

	// void UnloadPreviousRoom () {
	// 	if (prevRoom != null) {
	// 		prevRoom.gameObject.SetActive (false);
	// 	}
	// }

	// static Object ReturnRoomPrefab (RoomType type) {
	// 	Object returnRoom = null;
	// 	switch (type) {
	// 	default:
	// 	case RoomType.Gallery:
	// 		Resources.Load ("Room_Gallery");
	// 		break;
	// 	case RoomType.Beach:
	// 		Resources.Load ("Room_Beach");
	// 		break;
	// 	}
	// 	return returnRoom;
	// }

	// static List<Room> roomsObjectPool = new List<Room> ();
	// static Room SpawnRoom (Room prevRoom, RoomType type) {
	// 	Room returnRoom = null;
	// 	for (int i = 0; i < roomsObjectPool.Count; i++) {
	// 		if (!roomsObjectPool[i].gameObject.activeInHierarchy && roomsObjectPool[i].roomType == type) {
	// 			returnRoom = roomsObjectPool[i];
	// 			returnRoom.gameObject.SetActive (true);
	// 			returnRoom.transform.position = prevRoom.exitPoint;
	// 			break;
	// 		}
	// 	}

	// 	if (returnRoom == null) {
	// 		returnRoom = GameObject.Instantiate (ReturnRoomPrefab(type), prevRoom.exitPoint, Quaternion.identity) as Room;
	// 	}
	// 	return returnRoom;
	// }

}
