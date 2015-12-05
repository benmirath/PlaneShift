using UnityEngine;
using System.Collections;

public class RoomEntranceTrigger : MonoBehaviour {
	public delegate void PlayerEnteredRoom (RoomEntranceTrigger trigger);
	public static event PlayerEnteredRoom OnPlayerEnteredRoom;
//	Room owningRoom
	// Use this for initialization
//	void Start () {
//	
//	}
//	
//	// Update is called once per frame
//	void Update () {
//	
//	}

	void OnTriggerEnter (Collider hit) {
		if (hit.CompareTag ("Player")) {
			if (OnPlayerEnteredRoom != null) OnPlayerEnteredRoom (this);
		}
	}
}
