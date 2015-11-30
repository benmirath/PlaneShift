using UnityEngine;
//using UnityEngine.
using UnityEngine.Rendering;
using System.Collections.Generic;

public class HookShot : MonoBehaviour {

	Transform tr;
	Rigidbody rigid;
//	Rigidbody parentRigid;

	GameObject curTarget;
//	Joint hingeTarget;
	Controller controller;

	FixedJoint playerAnchor;

	public Transform anchorStart;

	public bool swinging { get; private set; }
	// Use this for initialization
	void Awake () {
		linkPool = new List<ConfigurableJoint> ();
		rigid = GetComponent<Rigidbody> ();
		playerAnchor = GetComponent<FixedJoint> ();
		controller = GetComponent<Controller> ();
		tr = transform;
		HookTarget.OnHookTargetAcquired += OnTargetAcquiredHandler;
	}
	void OnDestroy () {
		HookTarget.OnHookTargetAcquired -= OnTargetAcquiredHandler;
	}

	void Update () {

		RaycastHit hit;
		Color returnCol = Color.blue;
		if (Physics.Raycast (Camera.main.ViewportPointToRay (new Vector3 (0.5f, 0.5f, 0)), out hit, 300)) {
			Debug.LogWarning (hit.transform.name);
			returnCol = Color.red;
			HookTarget hook = hit.transform.GetComponent<HookTarget> ();
			if (hook != null) {
				hook.OnToggled (true);
				OnTargetAcquiredHandler (hit.transform.gameObject, true);
			}
		} else if (potentialTarget != null) {
			potentialTarget.GetComponent<HookTarget> ().OnToggled (false);
			OnTargetAcquiredHandler (potentialTarget.transform.gameObject, false);
		}

		if (!swinging) {
		    if (Input.GetButtonDown ("Fire1")) {
				SetGrapple (potentialTarget, 0);
			} else if (Input.GetButtonDown ("Fire2")) {
				SetGrapple (potentialTarget, 1);
			}
		} else {
			xSpeed = Input.GetAxis ("Horizontal");
			if(Input.GetButtonUp ("Fire1") || Input.GetButtonUp ("Fire2")) {
//				Debug.LogError ("Checl");
				FreeGrapple ();
			}
		}
	}

	float xSpeed;
	void fixedUpdate () {
		if (swinging) rigid.AddForce (rigid.transform.TransformDirection (new Vector3 (xSpeed, 0, 0)));
	}


	Transform curGrapple;
	void SetGrapple (GameObject targ, int grappleType) {
		if (targ == null) return;
		if (curTarget != null || curGrapple != null) FreeGrapple ();

		swinging = true;
		curTarget = targ;
		controller.SetActions (true, false);

		Rigidbody targRigid = curTarget.GetComponent<Rigidbody> ();
		if (targRigid != null && curTarget != null) {
			if (grappleType == 0) {


				Vector3 heading = (curTarget.transform.position + (Vector3.down *2) - tr.position) / 2;
				int dist = (int)heading.magnitude / 2;
				Vector3 normal = heading / dist;
				Vector3 startPos = normal;

				rigid.AddForce ((normal + Vector3.up) * 500, ForceMode.Impulse);

				GameObject wrapper = new GameObject ();
				wrapper.name = "Chain Wrapper";
				wrapper.transform.position = anchorStart.position + Vector3.forward + (normal * 2);
				Debug.LogWarning (wrapper.transform.position);

				ConfigurableJoint cachedJoint = null;
				for (int i = 0; i < dist - 1; i++) {
					ConfigurableJoint joint = SpawnHinge ();
					joint.transform.parent = wrapper.transform;
					joint.transform.localPosition = startPos;
					joint.transform.rotation = Quaternion.LookRotation (normal);

					if (cachedJoint != null) {
						Rigidbody rig = joint.GetComponent<Rigidbody> ();
						cachedJoint.connectedBody = rig;

						FixedJoint fixedJ = cachedJoint.GetComponent<FixedJoint> ();
						if (fixedJ == null) fixedJ = cachedJoint.gameObject.AddComponent <FixedJoint> ();
						fixedJ.connectedBody = rig;

					} else {	//start link
					
						Debug.LogWarning ("Boop");
						if (playerAnchor == null) playerAnchor = gameObject.AddComponent<FixedJoint> ();
						playerAnchor.connectedBody = joint.GetComponent<Rigidbody> ();
						playerAnchor.connectedBody.mass = 100;
					}


					cachedJoint = joint;
					startPos += normal * 2;
					Debug.LogWarning (startPos);
				}

				cachedJoint.connectedBody = targRigid;

				FixedJoint fixedJoint = cachedJoint.GetComponent<FixedJoint> ();
				if (fixedJoint == null) fixedJoint = cachedJoint.gameObject.AddComponent <FixedJoint> ();
				fixedJoint.connectedBody = targRigid;

				curGrapple = wrapper.transform;
			} else if (grappleType == 1) {
				SpringJoint target_spring = targRigid.gameObject.AddComponent <SpringJoint> ();
				target_spring.connectedBody = rigid;
				target_spring.autoConfigureConnectedAnchor = false;
				target_spring.connectedAnchor = targRigid.transform.position;
				target_spring.maxDistance = 50;
				target_spring.minDistance = 5;
			}
		}

//		Debug.LogError ("Coolio");
	}


	[SerializeField] ConfigurableJoint linkPrefab;
	List<ConfigurableJoint> linkPool;
	ConfigurableJoint SpawnHinge () {
		for (int i = 0; i < linkPool.Count; i++) {
			if (!linkPool[i].gameObject.activeInHierarchy) {
				linkPool[i].gameObject.SetActive (true);
				return linkPool[i];
			}
		}
		ConfigurableJoint joint = Instantiate (linkPrefab) as ConfigurableJoint;
		linkPool.Add (joint);
		return joint;
	}



	public void FreeGrapple () {
		if (curTarget != null) {
			curTarget = null;
			swinging = false;
		}

		if (curGrapple != null) {
			while (curGrapple.childCount > 0) {
				Transform curLink = curGrapple.GetChild (0);
				curLink.parent = null;
				curLink.gameObject.SetActive (false);
			}
			Destroy (curGrapple.gameObject);
		}
		controller.SetActions (true, true);
	}

	GameObject potentialTarget;
	void OnTargetAcquiredHandler (GameObject obj, bool entering) {
		if (entering) {
			potentialTarget = obj;
		} else {
			potentialTarget = null;
		}
	}
}
