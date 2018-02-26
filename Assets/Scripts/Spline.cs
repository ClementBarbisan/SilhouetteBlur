using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Spline : MonoBehaviour {
    public List<GameObject> points;
    public int nbrPoints = 50;
    LineRenderer line;
    List<Vector3> positions;
	// Use this for initialization
	void Start () {
        positions = new List<Vector3>();
        line = GetComponent<LineRenderer>();
		
	}
	
	// Update is called once per frame
	void Update () {
        positions.Clear();
        for (float i = 0; i < 1; i += (float)1 / (float)nbrPoints)
        {
            positions.Add(points[0].transform.position * Mathf.Pow(1 - i, 3) + 3 * points[1].transform.position * i * Mathf.Pow(1 - i, 2) + 3 * points[2].transform.position * Mathf.Pow(i, 2) * (1 - i) + points[3].transform.position * Mathf.Pow(i, 3));
        }
        line.positionCount = positions.Count;
        line.SetPositions(positions.ToArray());
    }
}
