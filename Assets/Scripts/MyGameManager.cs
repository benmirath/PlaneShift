using UnityEngine;
using System.Collections.Generic;

public class MyGameManager : MonoBehaviour {

// 	Start
// -create first room


// Update

// Create Room
// create foundation
// determine number of entrances 
// if 

	Controller2 player;
	[SerializeField]Controller2 playerPrefab;
	List<MyGameRoom> rooms;
	// Use this for initialization
	void Awake () {
		baseRoomPool = new ObjectPool<MyGameRoom> (baseRoomPrefab);
		wallPool = new ObjectPool<Transform> (wallPrefab);
		doorPool = new ObjectPool<Transform> (doorPrefab);
		
		rooms = new List<MyGameRoom> ();
		// MyGameRoom startRoom = new GameRoom (this, Vector3.zero);
		MyGameRoom startRoom = baseRoomPool.SpawnFromPool (Vector3.zero);
		startRoom.Initialize (this);
		rooms.Add (startRoom);
		
		player = Instantiate (playerPrefab, startRoom.roomPos + (Vector3.up * 5), Quaternion.identity) as Controller2;
	}
	
	// Update is called once per frame
	// void Update () {
	// }
	
	// void BuildRoom () {
		//create floor and ceiling
			//check if flip (1 : 5)?
		//create columns
			//add shader mat variant (normal, twisted, pulsing, blobby)
		//determine walls
			//if previous room isn't null, place door-wall there
			//determine number of doors (1 or 2)
				//place door-wall at each spot
				//place bridge at each spot
				//
			//place walls at rest of spots
		//determine decorations at each available wall spot (non-door)
			//painting
			//sculpture
			//note/reading
	// }
	// void OnTriggerEnter (Collider hit) {
		//Create and connect new rooms in next room
		//move trigger to new room
	// }
	
	
	
//==========================================
//OBJECT PREFABS
//==========================================
	// [SerializeField] Transform floorPrefab;
	[SerializeField] MyGameRoom baseRoomPrefab;
	[SerializeField] Transform wallPrefab;
	[SerializeField] Transform doorPrefab;
	
//==========================================
//OBJECT POOLS
//==========================================	
	// ObjectPool<Transform> floorPool;
	ObjectPool<MyGameRoom> baseRoomPool;
	public ObjectPool<Transform> wallPool;
	public ObjectPool<Transform> doorPool;	
}
