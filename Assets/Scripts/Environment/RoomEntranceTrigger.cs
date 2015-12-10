using UnityEngine;

[RequireComponent(typeof(BoxCollider))]
public class RoomEntranceTrigger : MonoBehaviour {
	public delegate void PlayerEnteredRoom (RoomEntranceTrigger trigger);
	public static event PlayerEnteredRoom OnPlayerEnteredRoom;

	void Awake () {
		BoxCollider coll = GetComponent<BoxCollider> ();
		if (coll != null) {
			coll.isTrigger = true;
			coll.size = new Vector3 (20, 20, 20);
		}
	}

	void OnTriggerEnter (Collider hit) {
		if (hit.CompareTag ("Player")) {
			if (OnPlayerEnteredRoom != null) OnPlayerEnteredRoom (this);
		}
	}
}
