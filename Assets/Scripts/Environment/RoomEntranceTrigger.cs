using UnityEngine;

[System.Serializable, RequireComponent(typeof(BoxCollider))]
public class RoomEntranceTrigger : MonoBehaviour {
	public delegate void PlayerEnteredRoom (RoomEntranceTrigger trigger);
	public static event PlayerEnteredRoom OnPlayerEnteredRoom;
	bool triggered = false;
	void Awake () {
		BoxCollider coll = GetComponent<BoxCollider> ();
		if (coll != null) {
			coll.isTrigger = true;
			coll.size = new Vector3 (20, 20, 20);
		}
	}
	
	void OnEnable () {
		triggered = false;
	}
	void OnTriggerEnter (Collider hit) {
		if (!triggered && hit.CompareTag ("Player")) {
			if (OnPlayerEnteredRoom != null) {
				triggered = true;
				OnPlayerEnteredRoom (this);
			}
		}
	}
}
