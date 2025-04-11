from setuptools import setup

setup(
    name="glance-minecraft-power",
    version="1.0.0",
    py_modules=["glance_minecraft_power"],
    install_requires=["flask"],
    entry_points={
        "console_scripts": [
            "glance-minecraft-power=glance_minecraft_power:main",
        ],
    },
)

