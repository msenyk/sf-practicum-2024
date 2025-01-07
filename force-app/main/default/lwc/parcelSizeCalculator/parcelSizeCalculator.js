import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getOrderProducts from '@salesforce/apex/OrderController.getOrderProducts';
import updateParcelDimensions from '@salesforce/apex/OrderController.updateParcelDimensions';
import binpackingjs from '@salesforce/resourceUrl/binpackingjs';
import THREE from '@salesforce/resourceUrl/three';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ParcelSizeCalculator extends LightningElement {
    @api recordId;
    @track orderProducts = [];
    @track boxSize;
    @track packingResult;
    binPackingLoaded = false;
    threeJsInitialized = false;
    sceneContainer;

    @wire(getRecord, { recordId: '$recordId', fields: ['Order.Name'] })
    order;

    @wire(getOrderProducts, { orderId: '$recordId' })
    wiredOrderProducts({ error, data }) {
        if (data) {
            this.orderProducts = data;
            this.loadScripts();
        } else if (error) {
            console.error(error);
        }
    }

    loadScripts() {
        this.loadThreeJs().then(() => this.loadBinPackingJs())
        .catch(error => {
                console.error('Error loading scripts:', error);
            });
    }

    loadThreeJs() {
        return new Promise((resolve, reject) => {
            if (this.threeJsInitialized) {
                resolve();
            } else {
                loadScript(this, THREE)
                    .then(() => {
                        this.threeJsInitialized = true;
                        resolve();
                    })
                    .catch(reject);
            }
        });
    }

    loadBinPackingJs() {
        return new Promise((resolve, reject) => {
            if (this.binPackingLoaded) {
                resolve();
            } else {
                loadScript(this, binpackingjs)
                    .then(() => {
                        this.binPackingLoaded = true;
                        resolve();
                    })
                    .catch(reject);
            }
        });
    }

    processOrderProducts() {
        try {
            let dimensions = [];
            this.orderProducts.forEach(product => {
                for (let i = 0; i < product.Quantity; i++) {
                    const { Width__c: width, Height__c: height, Length__c: length } = product.Product2;
                    dimensions.push([width, height, length]);
                }
            });
            const boxSolutions = this.calculateVolumetricTotal(dimensions);
            this.visualizePacking(boxSolutions);
        } catch (error) {
            console.error("LWC error: " + error);
        }
    }

    showErrorMessage(message) {
        const container = this.template.querySelector('.scene-container');
        if (container) {
            let errorMessageElement = container.querySelector('.error-message');
            if (!errorMessageElement) {
                errorMessageElement = document.createElement('div');
                errorMessageElement.classList.add('error-message');
                container.appendChild(errorMessageElement);
            }
            errorMessageElement.style.color = 'red';
            errorMessageElement.textContent = message;
        } else {
            console.error("Failed to get .scene-container");
        }
    }

    combination(list) {
        let combinations = [];
        const total = Math.pow(2, list.length);

        for (let i = 0; i < total; i++) {
            const set = list.filter((_, j) => (i & (1 << j)) !== 0);
            const sum = set.reduce((partialSum, a) => partialSum + a, 0);

            if (set.length && !combinations.includes(sum)) {
                combinations.push(sum);
            }
        }
        return combinations.sort();
    }

    calculateVolumetricTotal(dimensions) {
        let totalVolume = 0;
        let dims = { widthRange: [], heightRange: [], depthRange: [] };

        dimensions.forEach(dimension => {
            const [width, height, depth] = dimension.map(x => parseFloat(x));
            dims.widthRange.push(width);
            dims.heightRange.push(height);
            dims.depthRange.push(depth);
            totalVolume += width * height * depth;
        });

        for (const dim in dims) {
            dims[dim].sort();
        }

        const combinations = {
            width: this.combination(dims.widthRange),
            height: this.combination(dims.heightRange),
            depth: this.combination(dims.depthRange)
        };

        let stacks = {};
        combinations.width.forEach(width => {
            combinations.height.forEach(height => {
                combinations.depth.forEach(depth => {
                    const v = width * height * depth;
                    if (v >= totalVolume) {
                        stacks[v] = stacks[v] || {};
                        stacks[v][width + height + depth] = [width, height, depth];
                    }
                });
            });
        });

        return Object.fromEntries(
            Object.entries(stacks).sort(([v1], [v2]) => v1 > v2 ? -1 : 1),
        );
    }

    visualizePacking(boxSolutions) {
        let foundBin = null;
        let boxDimensions = null;

        for (const productId in boxSolutions) {
            for (const dimensionId in boxSolutions[productId]) {
                const dimensionsArray = boxSolutions[productId][dimensionId];
                if(dimensionsArray[0] > 47.4 || dimensionsArray[1] > 47.4 || dimensionsArray[2] > 48.5) continue;
                const { Item, Bin, Packer } = window.BP3D;
                const items = this.prepareItems();

                let packer = new Packer();
                packer.addBin(new Bin("Box", ...dimensionsArray.map(d => d / 100000), 100));
                items.forEach(item => packer.addItem(item));
                packer.pack();

                const bin = packer.bins[0];
                if (bin.items.length === items.length) {
                    foundBin = bin;
                    boxDimensions = dimensionsArray;
                    break;
                }
            }
            if (foundBin) break;
        }

        try {
            this.displayResults(!!foundBin, boxDimensions, foundBin);
        } catch (error) {
            console.error("LWC error: " + error);
        }
    }

    prepareItems() {
        const { Item } = window.BP3D;
        return this.orderProducts.flatMap((product, index) => (
            Array.from({ length: product.Quantity }, () => (
                new Item(
                    `${index + 1}`,
                    product.Product2.Width__c / 100000,
                    product.Product2.Height__c / 100000,
                    product.Product2.Length__c / 100000,
                    1
                )
            ))
        ));
    }

    displayResults(found, dimensions, bin) {
        const info = this.template.querySelector('.info');
        if (found) {
            this.initThreeJsScene(bin);
            this.createInfoBox(info, dimensions);
        } else {
            this.showErrorMessage("Failed to find the optimal size");
        }
    }

    createInfoBox(info, dimensions) {
        if (!info) return;
        info.innerHTML = '';
        const infoText = document.createElement('div');
        infoText.classList.add('slds-box', 'slds-theme_default', 'slds-m-bottom_small');
        infoText.innerHTML = `Optimal package dimensions: Width - ${dimensions[0]}, Height - ${dimensions[1]}, Depth - ${dimensions[2]}`;
        info.appendChild(infoText);
        const applyButton = document.createElement('button');
        applyButton.classList.add('slds-button', 'slds-button_neutral');
        applyButton.textContent = "Apply suggested package dimensions";
        applyButton.onclick = () => this.applySuggestedDimensions(dimensions);
        info.appendChild(applyButton);
        const button = this.template.querySelector('.calculateBoxSizeButton');
        if (button) {
            button.disabled = true;
        }
    }

    applySuggestedDimensions([width, height, depth]) {
        updateParcelDimensions({ orderId: this.recordId, width, height, depth })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Package dimensions successfully updated',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: `Error updating dimensions: ${error.body.message}`,
                        variant: 'error',
                    }),
                );
                console.error('Error updating dimensions: ', error);
            });
    }

    initThreeJsScene(bin) {
        this.sceneContainer = this.template.querySelector('.scene-container');
        if (!this.sceneContainer) return;

        this.sceneContainer.style.height = '450px';
        const scene = new window.THREE.Scene();
        scene.background = new window.THREE.Color(0xffffff);
        const camera = new window.THREE.PerspectiveCamera(75, this.sceneContainer.offsetWidth / this.sceneContainer.offsetHeight, 0.1, 1000);
        const renderer = new window.THREE.WebGLRenderer({ antialias: true });

        renderer.setSize(this.sceneContainer.offsetWidth, this.sceneContainer.offsetHeight);
        this.sceneContainer.appendChild(renderer.domElement);

        const controls = new window.THREE.OrbitControls(camera, renderer.domElement);
        this.addWireframe(scene, bin);
        this.addItemMeshes(scene, bin);

        const fontLoader = new window.THREE.FontLoader();
        fontLoader.load('https://threejs.org/examples/fonts/helvetiker_regular.typeface.json', (font) => {
            this.addItemLabels(bin, font, scene);
        });

        camera.position.set(bin.width * 1.5, bin.height * 1.5, bin.depth * 1.5);
        camera.lookAt(bin.width / 2, bin.height / 2, bin.depth / 2);

        this.animate(scene, camera, controls, renderer);
    }

    addWireframe(scene, bin) {
        const binGeometry = new window.THREE.BoxGeometry(bin.width, bin.height, bin.depth);
        const edges = new window.THREE.EdgesGeometry(binGeometry);
        const lineMaterial = new window.THREE.LineDashedMaterial({ color: 0x808080, dashSize: 2, gapSize: 1 });
        const binWireframe = new window.THREE.LineSegments(edges, lineMaterial);
        binWireframe.position.set(bin.width / 2, bin.height / 2, bin.depth / 2);
        binWireframe.computeLineDistances();
        scene.add(binWireframe);
    }

    addItemMeshes(scene, bin) {
        bin.items.forEach(item => {
            const [w, h, d] = item.getDimension();
            const [x, y, z] = item.position;

            const itemGeometry = new window.THREE.BoxGeometry(w, h, d);
            const itemMaterial = new window.THREE.MeshBasicMaterial({
                color: Math.random() * 0xffffff,
                opacity: 0.8,
                transparent: true
            });
            const itemMesh = new window.THREE.Mesh(itemGeometry, itemMaterial);

            itemMesh.position.set(x + w / 2, y + h / 2, z + d / 2);
            scene.add(itemMesh);
        });
    }

    animate(scene, camera, controls, renderer) {
        function renderScene() {
            requestAnimationFrame(renderScene);
            controls.update();
            renderer.render(scene, camera);
        }
        renderScene();
    }

    addItemLabels(bin, font, scene) {
        bin.items.forEach(item => {
            const [w, h, d] = item.getDimension();
            const [x, y, z] = item.position;
            const name = item.name || 'Unnamed';

            const textGeometry = new window.THREE.TextGeometry(name, {
                font: font,
                size: Math.min(w, h, d) / 4,
                height: 0.05,
                curveSegments: 12,
            });

            const textMaterial = new window.THREE.MeshBasicMaterial({ color: 0x000000 });
            const textMesh = new window.THREE.Mesh(textGeometry, textMaterial);

            textGeometry.computeBoundingBox();
            const textWidth = textGeometry.boundingBox.max.x - textGeometry.boundingBox.min.x;
            const textHeight = textGeometry.boundingBox.max.y - textGeometry.boundingBox.min.y;


            textMesh.position.set(
                x + w / 2 - textWidth / 2,
                y + h / 2 - textHeight / 2,
                z + d / 2 + 0.05
            );

            scene.add(textMesh);
        });
    }
} 